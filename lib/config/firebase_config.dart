import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'env_config.dart';

/// Firebase configuration using environment variables
class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase has not been configured for web.');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _getAndroidOptions();
      case TargetPlatform.iOS:
        return _getIosOptions();
      case TargetPlatform.macOS:
        throw UnsupportedError('Firebase has not been configured for macOS.');
      case TargetPlatform.windows:
        throw UnsupportedError('Firebase has not been configured for Windows.');
      case TargetPlatform.linux:
        throw UnsupportedError('Firebase has not been configured for Linux.');
      default:
        throw UnsupportedError('Firebase is not supported for this platform.');
    }
  }

  static FirebaseOptions _getAndroidOptions() {
    return FirebaseOptions(
      apiKey: EnvConfig.firebaseApiKeyAndroid,
      appId: EnvConfig.firebaseAppIdAndroid,
      messagingSenderId: EnvConfig.firebaseMessagingSenderId,
      projectId: EnvConfig.firebaseProjectId,
      storageBucket: EnvConfig.firebaseStorageBucket,
    );
  }

  static FirebaseOptions _getIosOptions() {
    return FirebaseOptions(
      apiKey: EnvConfig.firebaseApiKeyIos,
      appId: EnvConfig.firebaseAppIdIos,
      messagingSenderId: EnvConfig.firebaseMessagingSenderId,
      projectId: EnvConfig.firebaseProjectId,
      storageBucket: EnvConfig.firebaseStorageBucket,
      iosBundleId: EnvConfig.firebaseIosBundleId,
    );
  }
}
