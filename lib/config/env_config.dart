import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment configuration
/// This class manages all API keys and credentials from .env file
class EnvConfig {
  // Google Maps
  static String get googleMapsApiKey => dotenv.get('GOOGLE_MAPS_API_KEY', fallback: '');
  
  // Gemini AI
  static String get geminiApiKey => dotenv.get('GEMINI_API_KEY', fallback: '');
  
  // Firebase - Android
  static String get firebaseApiKeyAndroid => dotenv.get('FIREBASE_API_KEY_ANDROID', fallback: '');
  static String get firebaseAppIdAndroid => dotenv.get('FIREBASE_APP_ID_ANDROID', fallback: '');
  
  // Firebase - iOS
  static String get firebaseApiKeyIos => dotenv.get('FIREBASE_API_KEY_IOS', fallback: '');
  static String get firebaseAppIdIos => dotenv.get('FIREBASE_APP_ID_IOS', fallback: '');
  
  // Firebase - Common
  static String get firebaseMessagingSenderId => dotenv.get('FIREBASE_MESSAGING_SENDER_ID', fallback: '');
  static String get firebaseProjectId => dotenv.get('FIREBASE_PROJECT_ID', fallback: '');
  static String get firebaseStorageBucket => dotenv.get('FIREBASE_STORAGE_BUCKET', fallback: '');
  
  // Firebase - iOS Bundle ID
  static String get firebaseIosBundleId => dotenv.get('FIREBASE_IOS_BUNDLE_ID', fallback: '');
  
  // App Configuration
  static String get appEnv => dotenv.get('APP_ENV', fallback: 'development');
  
  /// Validates that all required environment variables are loaded
  static bool validateConfig() {
    final requiredVars = [
      'GOOGLE_MAPS_API_KEY',
      'GEMINI_API_KEY',
      'FIREBASE_PROJECT_ID',
      'FIREBASE_STORAGE_BUCKET',
    ];
    
    for (var variable in requiredVars) {
      if (dotenv.get(variable, fallback: '').isEmpty) {
        print('Error: Missing required environment variable: $variable');
        return false;
      }
    }
    
    return true;
  }
}
