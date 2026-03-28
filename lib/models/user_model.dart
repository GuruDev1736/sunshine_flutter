import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime lastLogin;
  final List<String> savedPlanIds; // IDs of saved/bookmarked plans
  final List<String> createdPlanIds; // IDs of plans created by this user
  final double averageRating;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    required this.createdAt,
    required this.lastLogin,
    this.savedPlanIds = const [],
    this.createdPlanIds = const [],
    this.averageRating = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "photoUrl": photoUrl,
      "bio": bio,
      "createdAt": Timestamp.fromDate(createdAt),
      "lastLogin": Timestamp.fromDate(lastLogin),
      "savedPlanIds": savedPlanIds,
      "createdPlanIds": createdPlanIds,
      "averageRating": averageRating,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"] ?? "",
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      photoUrl: map["photoUrl"],
      bio: map["bio"],
      createdAt: (map["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map["lastLogin"] as Timestamp?)?.toDate() ?? DateTime.now(),
      savedPlanIds: List<String>.from(map["savedPlanIds"] ?? []),
      createdPlanIds: List<String>.from(map["createdPlanIds"] ?? []),
      averageRating: (map["averageRating"] ?? 0).toDouble(),
    );
  }
}
