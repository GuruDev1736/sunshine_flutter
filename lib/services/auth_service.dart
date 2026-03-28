import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==================== EMAIL & PASSWORD ====================

  /// Register with email and password
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        // Update profile
        await user.updateDisplayName(name);
        await user.reload();

        // Create user profile in Firestore
        final userModel = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        await _firestoreService.saveUserProfile(userModel);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Login with email and password
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        await _firestoreService.updateLastLogin();
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ==================== GOOGLE SIGN-IN ====================

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw "Google sign-in cancelled by user";
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final user = result.user;

      if (user != null) {
        // Check if user exists, if not create profile
        final existingUser = await _firestoreService.getUserProfile(user.uid);
        if (existingUser == null) {
          final userModel = UserModel(
            uid: user.uid,
            name: user.displayName ?? "User",
            email: user.email ?? "",
            photoUrl: user.photoURL,
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
          );
          await _firestoreService.saveUserProfile(userModel);
        } else {
          await _firestoreService.updateLastLogin();
        }
      }

      return user;
    } catch (e) {
      throw "Google sign-in failed: $e";
    }
  }

  // ==================== PASSWORD MANAGEMENT ====================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw "No user logged in";
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ==================== ACCOUNT MANAGEMENT ====================

  /// Update user profile
  Future<void> updateUserProfile({
    required String name,
    String? photoUrl,
    String? bio,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw "No user logged in";
      }

      await user.updateDisplayName(name);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update in Firestore
      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: user.email ?? "",
        photoUrl: photoUrl ?? user.photoURL,
        bio: bio,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      await _firestoreService.saveUserProfile(userModel);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw "No user logged in";
      }

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ==================== LOGOUT ====================

  /// Sign out user
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw "Logout failed: $e";
    }
  }

  // ==================== WRAPPER METHODS ====================

  /// Wrapper method for login (calls loginWithEmail)
  Future<User?> login(String email, String password) async {
    return loginWithEmail(email: email, password: password);
  }

  /// Wrapper method for register (calls registerWithEmail)
  Future<User?> register(String email, String password, String name) async {
    return registerWithEmail(email: email, password: password, name: name);
  }

  /// Send password reset email
  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ==================== HELPER METHODS ====================

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'This operation requires recent login.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  /// Check if email exists
  Future<bool> isEmailRegistered(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
}
