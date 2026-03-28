import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'config/firebase_config.dart';
import 'app.dart';
import 'config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preserve native splash screen
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
  // Validate that all required configuration is loaded
  if (!EnvConfig.validateConfig()) {
    throw Exception('Failed to load required environment configuration');
  }

  await Firebase.initializeApp(
    options: FirebaseConfig.currentPlatform,
  );

  // Remove native splash screen
  FlutterNativeSplash.remove();

  runApp(const SunshineApp());
}
