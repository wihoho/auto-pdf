# Build Instructions for Auto PDF Converter

## Prerequisites

1. **Flutter SDK**: Install Flutter SDK (3.0.0 or later)
   - Download from: https://flutter.dev/docs/get-started/install/windows
   - Add Flutter to your PATH environment variable

2. **Visual Studio**: Install Visual Studio 2019 or later with C++ development tools
   - Required for Windows desktop development

3. **Git**: Install Git for version control

## Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd auto-pdf-converter
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Enable Windows desktop support** (if not already enabled):
   ```bash
   flutter config --enable-windows-desktop
   ```

## Development

### Running in Debug Mode

```bash
flutter run -d windows
```

### Hot Reload
While the app is running, you can make changes to the code and press `r` in the terminal to hot reload.

## Building for Release

### Build Release Version

```bash
flutter build windows --release
```

The built application will be located in:
```
build/windows/runner/Release/
```

### Create Distributable Package

1. **Copy required files**:
   ```bash
   # Create distribution folder
   mkdir dist
   
   # Copy the executable and required DLLs
   cp -r build/windows/runner/Release/* dist/
   
   # Copy any additional assets if needed
   cp -r assets dist/ (if you have assets)
   ```

2. **Test the distribution**:
   - Navigate to the `dist` folder
   - Run `auto_pdf_converter.exe` to ensure it works standalone

## Testing

### Manual Testing Checklist

1. **Application Launch**:
   - [ ] Application starts without errors
   - [ ] Main window displays correctly
   - [ ] All UI elements are visible and functional

2. **Folder Selection**:
   - [ ] "Browse for Folder" button opens file picker
   - [ ] Selected folder path is displayed correctly
   - [ ] Can clear folder selection

3. **Monitoring Functionality**:
   - [ ] "Start Monitoring" button works when folder is selected
   - [ ] "Stop Monitoring" button works when monitoring is active
   - [ ] Status indicator shows correct state

4. **File Conversion**:
   - [ ] Create a test PowerPoint file (.pptx)
   - [ ] Copy it to the monitored folder
   - [ ] Verify PDF is created automatically
   - [ ] Check that original file remains unchanged

5. **Error Handling**:
   - [ ] Test with corrupted PowerPoint file
   - [ ] Test with folder that doesn't exist
   - [ ] Test without PowerPoint installed (should show warning)

6. **Logging**:
   - [ ] Activity log shows conversion events
   - [ ] Error messages are displayed clearly
   - [ ] Log can be cleared and copied

### Automated Testing

Run Flutter tests:
```bash
flutter test
```

## Troubleshooting Build Issues

### Common Issues

1. **"Flutter command not found"**:
   - Ensure Flutter is added to your PATH
   - Restart your terminal/command prompt

2. **"Visual Studio not found"**:
   - Install Visual Studio with C++ development tools
   - Run `flutter doctor` to verify setup

3. **"Windows desktop not supported"**:
   - Run `flutter config --enable-windows-desktop`
   - Ensure you're using Flutter 2.0 or later

4. **Missing dependencies**:
   - Run `flutter pub get` to install all dependencies
   - Check pubspec.yaml for any version conflicts

### Verification Commands

Check your Flutter setup:
```bash
flutter doctor -v
```

Check available devices:
```bash
flutter devices
```

## Performance Optimization

### Release Build Optimizations

The release build automatically includes:
- Code obfuscation
- Tree shaking (removes unused code)
- Minification
- AOT compilation for better performance

### Additional Optimizations

1. **Reduce app size**:
   ```bash
   flutter build windows --release --split-debug-info=debug-info --obfuscate
   ```

2. **Profile performance**:
   ```bash
   flutter run --profile -d windows
   ```

## Deployment

### Creating an Installer (Optional)

You can use tools like:
- **Inno Setup**: Create a Windows installer
- **NSIS**: Nullsoft Scriptable Install System
- **WiX Toolset**: Windows Installer XML

### Distribution Checklist

Before distributing:
- [ ] Test on clean Windows machine
- [ ] Verify PowerPoint integration works
- [ ] Check all dependencies are included
- [ ] Test with different PowerPoint versions
- [ ] Verify system tray functionality
- [ ] Test file permissions and UAC

## Maintenance

### Updating Dependencies

```bash
flutter pub upgrade
```

### Checking for Security Issues

```bash
flutter pub deps
```

### Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.1+2  # version+build_number
```

Then rebuild:
```bash
flutter build windows --release
```
