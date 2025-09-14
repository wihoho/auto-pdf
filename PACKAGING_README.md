# Auto PDF Converter - Packaging Guide

This guide explains how to build and package the Auto PDF Converter Flutter app for Windows distribution.

## Prerequisites

1. **Flutter SDK** - Make sure Flutter is installed and configured
2. **PowerShell** - For running build and install scripts (built-in on Windows)
3. **Windows development environment**

## Quick Build & Package

### Option 1: Using the PowerShell Script (Recommended)

1. Open PowerShell as Administrator
2. Navigate to the project directory
3. Run: `.\build_installer.ps1`

This will:
- Clean previous builds
- Build the Flutter app in release mode
- Create distribution packages

### Option 2: Manual Steps

1. **Build the Flutter app:**
   ```bash
   flutter build windows --release
   ```

## Output Files

After building, you'll have these distribution options:

- **Portable ZIP:** `AutoPDFConverter_1.0.0_Portable.zip` - Extract and run anywhere
- **Built app directory:** `build\windows\x64\runner\Release\` - For manual installation

## Distribution Methods

### Method 1: Portable ZIP (Simplest)

The `AutoPDFConverter_1.0.0_Portable.zip` file can be distributed as-is. Users can:
1. Extract the ZIP file to any location
2. Run `auto_pdf_converter.exe` directly
3. No installation required

### Method 2: Simple Installer Script

Use the provided `install.ps1` script for a more traditional installation:

```powershell
# Install to default location (Program Files)
.\install.ps1

# Install to custom location
.\install.ps1 -InstallPath "C:\MyApps\Auto PDF Converter"

# Uninstall
.\install.ps1 -Uninstall
```

The installer will:
- Copy files to Program Files (or custom location)
- Create desktop and Start Menu shortcuts
- Provide an uninstall script

### Method 3: Professional Installer (Advanced)

For a professional installer with Inno Setup:

1. Download and install [Inno Setup](https://jrsoftware.org/isdl.php)
2. Add Inno Setup to your system PATH
3. Run: `iscc installer.iss`
4. This creates: `installer\AutoPDFConverter_1.0.0_Installer.exe`

## Requirements for End Users

- Windows 10 or later
- Microsoft PowerPoint and/or Word installed (for PDF conversion)
- Administrator privileges for installation (if using installer)

## Troubleshooting

### Flutter Build Issues
Make sure Flutter is properly installed and your environment is set up:
```bash
flutter doctor
```

### Permission Issues
Run build and install scripts as Administrator to avoid permission issues.

### Missing Dependencies
The app includes all necessary Flutter dependencies in the build. Microsoft Office applications (PowerPoint/Word) must be installed separately on end-user systems.

## File Structure

```
Auto PDF Converter/
├── auto_pdf_converter.exe    # Main executable
├── flutter_windows.dll       # Flutter runtime
├── data/                     # Application data
├── assets/                   # App assets (icons, etc.)
└── install.ps1              # Simple installer script
```