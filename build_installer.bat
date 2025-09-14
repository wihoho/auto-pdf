@echo off
echo ========================================
echo Auto PDF Converter - Build Script
echo ========================================
echo.

echo Step 1: Cleaning previous builds...
if exist "build" rmdir /s /q "build"
if exist "installer" rmdir /s /q "installer"
echo.

echo Step 2: Building Flutter Windows app...
flutter build windows --release
if %errorlevel% neq 0 (
    echo ERROR: Flutter build failed!
    pause
    exit /b 1
)
echo.

echo Step 3: Checking for Inno Setup...
where iscc >nul 2>nul
if %errorlevel% neq 0 (
    echo WARNING: Inno Setup Compiler (iscc.exe) not found in PATH.
    echo.
    echo To create the installer, please:
    echo 1. Download and install Inno Setup from: https://jrsoftware.org/isdl.php
    echo 2. Add Inno Setup to your system PATH
    echo 3. Run this script again
    echo.
    echo Alternatively, you can manually run:
    echo iscc installer.iss
    echo.
    echo The built app is available in: build\windows\x64\runner\Release\
    pause
    exit /b 0
)

echo Step 4: Creating Windows installer...
iscc installer.iss
if %errorlevel% neq 0 (
    echo ERROR: Installer creation failed!
    pause
    exit /b 1
)
echo.

echo ========================================
echo Build completed successfully!
echo ========================================
echo.
echo Installer created: installer\AutoPDFConverter_1.0.0_Installer.exe
echo Built app location: build\windows\x64\runner\Release\
echo.
echo To install the app, run the installer as administrator.
echo.
pause