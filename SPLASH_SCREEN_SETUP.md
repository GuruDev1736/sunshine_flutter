# Splash Screen Setup Guide

## Overview
Your app now has an enhanced splash screen implementation with:
- **Native Splash Screen**: Displays immediately when the app launches (before Flutter engine loads)
- **Animated Splash Screen**: Custom Flutter screen with smooth animations while initializing Firebase

## Implementation Details

### Changes Made:

1. **pubspec.yaml**
   - Added `flutter_native_splash: ^2.4.0` dependency
   - Configured native splash screen with your app's logo and colors

2. **lib/main.dart**
   - Added `flutter_native_splash` imports
   - Preserved native splash during app initialization
   - Removed splash after Firebase setup completes

3. **lib/screens/splash_screen.dart**
   - Enhanced with multiple animations:
     - Fade transition for entire content
     - Scale animation with elastic curve for logo
     - Rotating progress indicator
     - Loading text message

## Setup Instructions

### Step 1: Install Dependencies
Run this command to install the new package:
```bash
flutter pub get
```

### Step 2: Generate Native Splash Assets
Generate the native splash screen assets for all platforms:
```bash
dart run flutter_native_splash:create
```

This command will:
- Create native splash screen configuration for Android
- Create native splash screen configuration for iOS
- Use the logo from `assets/images/logo.png`
- Apply the color scheme `#FF6B4C` (Sunshine Orange)

### Step 3: Verify Installation
After running the setup command, check that:
- Android: `android/app/src/main/res/` contains splash screen drawables
- iOS: `ios/Runner/Assets.xcassets/` is configured
- Native splash displays when you run the app

## Customization

### Change Splash Colors
Edit the `flutter_native_splash` section in `pubspec.yaml`:
```yaml
flutter_native_splash:
  color: "#FF6B4C"           # Light mode color
  color_dark: "#FF6B4C"      # Dark mode color
```

### Change Splash Image
Replace `assets/images/logo.png` with your preferred image and update `pubspec.yaml`:
```yaml
  image: assets/images/your_image.png
```

### Adjust Animation Duration
Modify the animation durations in `lib/screens/splash_screen.dart`:
```dart
_fadeController = AnimationController(
  duration: const Duration(milliseconds: 1200), // Change this
  vsync: this,
);
```

### Change Navigation Delay
Modify the delay before navigation in `_navigateToNextScreen()`:
```dart
Future.delayed(const Duration(seconds: 3), () {  // Change seconds value
  // Navigation code
});
```

## Platform-Specific Notes

### Android
- Splash screen displays during app launch
- Compatible with Android 12+ Material Design 3
- Automatically handles notches and safe areas

### iOS
- Splash screen displays during app initialization
- Uses Launch Screen configuration
- Maintains landscape and portrait orientations

## Testing

### Run the App
```bash
flutter run
```

You should see:
1. Native splash screen appears immediately
2. After ~3 seconds, custom Flutter splash screen displays
3. App navigates to Home (if logged in) or Login screen

### Test on Specific Platform
```bash
flutter run -d android    # Run on Android
flutter run -d ios        # Run on iOS (macOS required)
```

## Troubleshooting

### Native Splash Not Appearing
1. Run `dart run flutter_native_splash:clean` to remove old files
2. Run `dart run flutter_native_splash:create` again
3. Rebuild the app: `flutter clean && flutter pub get && flutter run`

### Logo Image Not Showing
- Ensure `assets/images/logo.png` exists
- Check that the asset is listed in `pubspec.yaml`
- Verify file format (PNG recommended, max 320x320 pixels)

### Animation Stuttering
- Reduce animation controller durations
- Check device performance
- Use `flutter run --profile` to test performance build

## Best Practices

1. **Keep It Short**: 2-3 seconds is ideal for splash duration
2. **Large Logo**: Use at least 192x192 pixels for clarity
3. **Simple Design**: Avoid complex animations that slow app startup
4. **Test on Devices**: Native splash behavior varies by OS version
5. **No Network Calls**: Finish all initialization before showing custom splash

## Files Modified

- `pubspec.yaml` - Added dependency and configuration
- `lib/main.dart` - Added splash lifecycle management
- `lib/screens/splash_screen.dart` - Enhanced UI and animations

Generated files (after running setup):
- `android/app/src/main/splash-screen/` - Android native resources
- `ios/Runner/Assets.xcassets/` - iOS splash configuration
