param(
    [switch]$CleanOnly,
    [switch]$BuildOnly,
    [switch]$Help
)

if ($Help) {
    Write-Host "Auto PDF Converter - Build Script"
    Write-Host ""
    Write-Host "Usage: .\build_installer.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -CleanOnly    Only clean previous builds"
    Write-Host "  -BuildOnly    Only build the app, don't create installer"
    Write-Host "  -Help         Show this help message"
    Write-Host ""
    Write-Host "Without options: Clean, build, and create installer"
    exit 0
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Auto PDF Converter - Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "It's recommended to run this script as Administrator to avoid permission issues."
    $response = Read-Host "Continue anyway? (y/N)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        exit 1
    }
}

if (-not $CleanOnly -and -not $BuildOnly) {
    Write-Host "Step 1: Cleaning previous builds..." -ForegroundColor Yellow
    if (Test-Path "build") { Remove-Item "build" -Recurse -Force }
    if (Test-Path "installer") { Remove-Item "installer" -Recurse -Force }
    Write-Host ""
}

if ($CleanOnly) {
    Write-Host "Clean completed." -ForegroundColor Green
    exit 0
}

Write-Host "Step 2: Building Flutter Windows app..." -ForegroundColor Yellow
try {
    & flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter build failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Error "ERROR: Flutter build failed! $($_.Exception.Message)"
    exit 1
}
Write-Host ""

if ($BuildOnly) {
    Write-Host "Build completed successfully!" -ForegroundColor Green
    Write-Host "Built app location: build\windows\x64\runner\Release\" -ForegroundColor Green
    exit 0
}

Write-Host "Step 3: Checking for Inno Setup..." -ForegroundColor Yellow
try {
    $isccPath = Get-Command iscc -ErrorAction Stop
    Write-Host "Inno Setup found: $($isccPath.Source)" -ForegroundColor Green
} catch {
    Write-Warning "Inno Setup Compiler (iscc.exe) not found in PATH."
    Write-Host ""
    Write-Host "To create the installer, please:" -ForegroundColor Yellow
    Write-Host "1. Download and install Inno Setup from: https://jrsoftware.org/isdl.php" -ForegroundColor Yellow
    Write-Host "2. Add Inno Setup to your system PATH" -ForegroundColor Yellow
    Write-Host "3. Run this script again" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Alternatively, you can manually run:" -ForegroundColor Yellow
    Write-Host "iscc installer.iss" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "The built app is available in: build\windows\x64\runner\Release\" -ForegroundColor Green
    exit 0
}

Write-Host "Step 4: Creating Windows installer..." -ForegroundColor Yellow
try {
    & iscc installer.iss
    if ($LASTEXITCODE -ne 0) {
        throw "Inno Setup compilation failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Error "ERROR: Installer creation failed! $($_.Exception.Message)"
    exit 1
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Installer created: installer\AutoPDFConverter_1.0.0_Installer.exe" -ForegroundColor Green
Write-Host "Built app location: build\windows\x64\runner\Release\" -ForegroundColor Green
Write-Host ""
Write-Host "To install the app, run the installer as administrator." -ForegroundColor Cyan
Write-Host ""