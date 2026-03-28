# Environment Configuration Guide

This document explains how to set up and manage environment variables for the Sunshine Holiday Packages app.

## Overview

The application uses a `.env` file to centrally manage all API keys and credentials. This approach:
- ✅ Keeps sensitive information out of version control
- ✅ Allows different configurations for different environments
- ✅ Makes it easy to update credentials without code changes
- ✅ Simplifies local development setup

## Files Created

### 1. `.env` (Main Configuration File)
- **Location**: Root of the project
- **Purpose**: Contains actual API keys and credentials
- **Security**: Added to `.gitignore` - never committed to version control
- **Setup**: Copy from `.env.example` and fill in your actual values

### 2. `.env.example` (Template)
- **Location**: Root of the project
- **Purpose**: Template showing all required environment variables
- **Use**: Commit to version control; team members copy this to `.env`

### 3. `lib/config/env_config.dart` (Configuration Class)
- **Purpose**: Centralized access to environment variables
- **Use**: Import and use `EnvConfig` class in your services
- **Example**:
  ```dart
  import 'package:your_app/config/env_config.dart';
  
  final apiKey = EnvConfig.googleMapsApiKey;
  final geminiKey = EnvConfig.geminiApiKey;
  ```

### 4. `lib/config/firebase_config.dart` (Firebase Configuration)
- **Purpose**: Dynamic Firebase configuration using environment variables
- **Use**: Automatically loaded in `main.dart`

## Setup Instructions

### Step 1: Create Your `.env` File

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Open `.env` and fill in your actual values:
   ```env
   GOOGLE_MAPS_API_KEY=your_actual_key_here
   GEMINI_API_KEY=your_actual_key_here
   FIREBASE_API_KEY_ANDROID=your_actual_key_here
   # ... etc
   ```

### Step 2: Verify Configuration

The app automatically validates all required environment variables on startup. If any are missing, the app will throw an exception.

### Step 3: Running the App

No special setup needed! Just run normally:
```bash
flutter run
```

The `.env` file will be automatically loaded.

## Available Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `GOOGLE_MAPS_API_KEY` | Google Maps API key for polyline routing | `AIzaSy...` |
| `GEMINI_API_KEY` | Google Gemini AI API key | `AIzaSy...` |
| `FIREBASE_API_KEY_ANDROID` | Firebase API key for Android | `AIzaSy...` |
| `FIREBASE_API_KEY_IOS` | Firebase API key for iOS | `AIzaSy...` |
| `FIREBASE_APP_ID_ANDROID` | Firebase app ID for Android | `1:123456:android:abc...` |
| `FIREBASE_APP_ID_IOS` | Firebase app ID for iOS | `1:123456:ios:abc...` |
| `FIREBASE_MESSAGING_SENDER_ID` | Firebase messaging sender ID | `123456789` |
| `FIREBASE_PROJECT_ID` | Firebase project ID | `project-name-123` |
| `FIREBASE_STORAGE_BUCKET` | Firebase storage bucket | `project.firebasestorage.app` |
| `FIREBASE_IOS_BUNDLE_ID` | iOS bundle identifier | `com.example.app` |
| `APP_ENV` | Application environment | `development` or `production` |

## Usage Examples

### Using in Services

#### Before (Hardcoded)
```dart
class GeminiService {
  static const String apiKey = "AIzaSyBf9MoMmXpPnQnKfZK28WGVBdOUuWkRCS8";
}
```

#### After (Using .env)
```dart
import 'package:your_app/config/env_config.dart';

class GeminiService {
  late final String apiKey;
  
  GeminiService() {
    apiKey = EnvConfig.geminiApiKey;
  }
}
```

### Using Multiple Keys

```dart
import 'package:your_app/config/env_config.dart';

class MyService {
  String get mapsKey => EnvConfig.googleMapsApiKey;
  String get geminiKey => EnvConfig.geminiApiKey;
  String get projectId => EnvConfig.firebaseProjectId;
}
```

## Environment-Specific Configurations

For different environments (development, staging, production), create separate `.env` files:

```
.env.development       # Development environment
.env.staging          # Staging environment
.env.production       # Production environment (should never be in Git)
.env                  # Current active environment
```

To switch environments:
```bash
# For development
cp .env.development .env

# For production
cp .env.production .env
```

Or update `main.dart` to load based on `APP_ENV`:
```dart
String envFile = dotenv.get('APP_ENV', fallback: 'development') == 'production' 
  ? '.env.production' 
  : '.env.development';
  
await dotenv.load(fileName: envFile);
```

## Security Best Practices

1. ✅ **Never commit `.env` to Git** - It's in `.gitignore`
2. ✅ **Share `.env.example` instead** - Shows structure without secrets
3. ✅ **Use specific keys per environment** - Different keys for dev/prod
4. ✅ **Rotate keys regularly** - Update old keys periodically
5. ✅ **Validate configuration on startup** - App won't run without required keys
6. ✅ **Use environment-specific credentials** - Never use production keys in development

## Common Issues & Solutions

### Issue: "Failed to load required environment configuration"
**Solution**: 
- Check that `.env` file exists in project root
- Verify all required variables are in `.env` with non-empty values
- Ensure file encoding is UTF-8

### Issue: Keys still showing as hardcoded
**Solution**:
- Make sure you imported `EnvConfig` correctly
- Use `EnvConfig.variableName` instead of hardcoded strings
- Rebuild the app after changes

### Issue: ".env" not found error
**Solution**:
- The `.env` file should be in the project root, not in `lib/` or other folders
- Make sure `.env` is listed in `pubspec.yaml` under assets

## Related Files Modified

The following files were updated to use centralized environment configuration:

1. **`lib/main.dart`** - Loads `.env` and validates configuration
2. **`lib/services/maps_service.dart`** - Uses `EnvConfig.googleMapsApiKey`
3. **`lib/services/gemini_service.dart`** - Uses `EnvConfig.geminiApiKey`
4. **`lib/firebase_options.dart`** - Can be kept as-is (backup reference)

## Additional Resources

- [flutter_dotenv Documentation](https://pub.dev/packages/flutter_dotenv)
- [Firebase Configuration](https://firebase.flutter.dev/)
- [12-Factor App - Configuration](https://12factor.net/config)

## Questions?

For more information about environment variables in this project, refer to:
- `lib/config/env_config.dart` - Configuration class implementation
- `lib/config/firebase_config.dart` - Firebase dynamic configuration
- `.env.example` - All available variables and their purposes
