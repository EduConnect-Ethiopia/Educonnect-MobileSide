# EduConnect Logo Setup Guide

## Overview
The flutter_launcher_icons configuration in `pubspec.yaml` expects an icon image at `assets/icons/app_icon.png`.

## EduConnect Logo Specifications

**Design Description:**
- Interconnected paper clippers at diagonal orientation
- Blue background with clippers positioned at the diagonal center
- Silver/White color for the clippers (interconnected design)
- Rounded modern aesthetic suitable for mobile apps

## Steps to Add Your Logo

### Option 1: Using an Existing Logo File

1. **Prepare your logo file:**
   - Convert to PNG format (if not already)
   - Recommended size: 1024x1024 pixels minimum
   - Should have transparency where needed
   - File name: `app_icon.png`

2. **Place the file in this directory:**
   ```
   assets/icons/app_icon.png
   ```

3. **Update pubspec.yaml (if needed):**
   - The configuration is already present:
   ```yaml
   flutter_icons:
     android: true
     ios: true
     image_path: "assets/icons/app_icon.png"
   ```

### Option 2: Create Logo Using Design Tools

If you don't have a pre-made logo, use one of these tools:
- **Figma** (Free): https://www.figma.com
- **Adobe Express** (Free): https://www.adobe.com/express
- **Canva** (Free): https://www.canva.com
- **Photoshop** or **GIMP** (Free GIMP)

**Design Steps:**
1. Create 1024x1024px canvas
2. Set background to blue (recommended: #0066CC or similar)
3. Add white/silver interconnected paper clips in diagonal orientation
4. Position clippers at the diagonal center
5. Export as PNG with transparency
6. Save as `app_icon.png` in this directory

### Option 3: Generate Icon from EduConnect Brand Assets

If you have brand guidelines or existing assets:
1. Use the primary logo file
2. Ensure it's at least 1024x1024 pixels
3. Background should be blue with white/silver clippers
4. Place in `assets/icons/app_icon.png`

## Applying the Icon

Once you have `app_icon.png` in place, run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

This will:
- Generate Android app icons (mipmaps for different densities)
- Generate iOS app icons (different sizes)
- Update platform-specific configuration files

## Verification

### Android:
- Check `android/app/src/main/res/` for generated mipmap folders
- Verify in Android manifest that launcher icon is set correctly

### iOS:
- Check `ios/Runner/Assets.xcassets/AppIcon.appiconset/` for generated icons
- Verify in Xcode project

## Platform Support

The flutter_launcher_icons configuration currently supports:
- ✅ Android: Yes (`android: true`)
- ✅ iOS: Yes (`ios: true`)
- ⚠️ Web: Configure separately if needed
- ⚠️ Windows/Linux: Configure separately if needed

## Splash Screen

The splash screen will use the app icon by default on Android. For custom splash screens, see:
- [Flutter Splash Screen Documentation](https://flutter.dev/docs/development/ui/advanced/splash-screen)
- Current splash screen: `lib/presentation/screens/splash/splash_screen.dart`

## Troubleshooting

### Icons not updating:
```bash
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons:main
```

### Build cache issues:
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter run
```

### Icon looks blurry:
- Ensure source image is at least 1024x1024 pixels
- Use high-quality PNG without compression artifacts

## File Structure After Icon Generation

```
assets/icons/
├── app_icon.png           (your source icon)
└── LOGO_SETUP.md         (this file)

android/app/src/main/res/
├── mipmap-hdpi/
├── mipmap-mdpi/
├── mipmap-xhdpi/
├── mipmap-xxhdpi/
└── mipmap-xxxhdpi/
   └── ic_launcher.png    (generated for each density)

ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── AppIcon.png           (various sizes)
├── AppIcon@2x.png
├── AppIcon@3x.png
└── Contents.json
```

## Next Steps

1. ✅ Create your `assets/icons/app_icon.png` logo file
2. ✅ Run `flutter pub run flutter_launcher_icons:main`
3. ✅ Verify icons in both Android and iOS projects
4. ✅ Test on actual devices if possible
5. ✅ Commit generated files to git

---

**Status:** Pending logo image placement
**Last Updated:** Commit 4 - Mobile-Backend Integration
