# macOS Setup Guide

This document provides instructions for completing the macOS support implementation.

## ✅ Completed Implementation

The core macOS support has been implemented with the following features:

### Platform-Specific Conversion
- **Windows**: PowerShell automation (existing)
- **macOS**: AppleScript automation with Microsoft PowerPoint
- Automatic platform detection and conditional execution

### macOS Platform Files
- `macos/Runner/DebugProfile.entitlements` - Debug permissions
- `macos/Runner/Release.entitlements` - Release permissions  
- `macos/Runner/Info.plist` - App metadata
- `macos/CMakeLists.txt` - Build configuration

### Enhanced ConversionService
- Cross-platform conversion logic
- macOS-specific AppleScript methods
- Platform-specific PowerPoint detection

## 🚧 Remaining Setup Steps

### 1. CI/CD Workflow Setup

Due to GitHub workflow scope limitations, the CI/CD workflow needs to be added manually by a repository admin:

**File**: `.github/workflows/build_and_test.yml`

```yaml
name: Build & Test Flutter App

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build-and-test-windows:
    runs-on: windows-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Flutter SDK
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          flutter-version-file: 'pubspec.yaml'
          cache: true

      - name: Get Flutter dependencies
        run: flutter pub get

      - name: Run static code analysis
        run: flutter analyze --fatal-infos

      - name: Run unit and widget tests
        run: flutter test

      - name: Build Windows release
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        run: flutter build windows --release

      - name: Upload Windows build artifact
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        uses: actions/upload-artifact@v4
        with:
          name: windows-build-${{ github.sha }}
          path: build/windows/x64/runner/Release/

  build-and-test-macos:
    runs-on: macos-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Flutter SDK
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          flutter-version-file: 'pubspec.yaml'
          cache: true

      - name: Get Flutter dependencies
        run: flutter pub get

      - name: Run static code analysis
        run: flutter analyze --fatal-infos

      - name: Run unit and widget tests
        run: flutter test

      - name: Build macOS release
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        run: flutter build macos --release

      - name: Upload macOS build artifact
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        uses: actions/upload-artifact@v4
        with:
          name: macos-build-${{ github.sha }}
          path: build/macos/Build/Products/Release/*.app
```

### 2. Branch Protection Rules

Update branch protection rules to require both Windows and macOS checks:
1. Go to Settings > Branches > main
2. Add `build-and-test-macos` to required status checks
3. Ensure both `build-and-test-windows` and `build-and-test-macos` are required

### 3. Complete Flutter macOS Setup

On a macOS development machine:

```bash
# Generate complete macOS platform files
flutter create . --platforms=macos

# Install dependencies
flutter pub get

# Build and test
flutter build macos --release
```

## 🧪 Testing Requirements

### macOS Prerequisites
- macOS 10.14+ (Mojave or later)
- Microsoft PowerPoint for Mac installed
- Flutter SDK with macOS support enabled

### Test Scenarios
1. **File Selection**: Verify folder picker works on macOS
2. **File Watching**: Test directory monitoring functionality  
3. **PowerPoint Detection**: Confirm PowerPoint installation detection
4. **Conversion Process**: Test PPT/PPTX to PDF conversion with AppleScript
5. **Error Handling**: Verify graceful handling of missing PowerPoint

## 📋 Acceptance Criteria Checklist

- [x] macOS directory structure created
- [x] Platform-specific conversion logic implemented  
- [x] File system permissions configured
- [x] Cross-platform PowerPoint detection
- [x] All existing functionality preserved
- [ ] CI/CD workflow active (requires admin setup)
- [ ] Branch protection rules updated (requires admin access)
- [ ] macOS build artifacts generated
- [ ] End-to-end testing on macOS completed

## 🔧 Troubleshooting

### Common Issues
1. **AppleScript Permission Denied**: Ensure app has accessibility permissions
2. **PowerPoint Not Found**: Verify Microsoft PowerPoint for Mac is installed
3. **File Access Denied**: Check entitlements are properly configured
4. **Build Failures**: Ensure Xcode and CocoaPods are installed

### Debug Commands
```bash
# Check PowerPoint availability
osascript -e 'tell application "System Events" to return exists application "Microsoft PowerPoint"'

# Test file permissions
ls -la /path/to/test/directory

# Verify Flutter macOS setup
flutter doctor -v
```
