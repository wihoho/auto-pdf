#Requires -RunAsAdministrator

param(
    [string]$InstallPath = "$env:ProgramFiles\Auto PDF Converter",
    [switch]$Uninstall,
    [switch]$Help
)

$AppName = "Auto PDF Converter"
$AppVersion = "1.0.0"
$Publisher = "Auto PDF Converter Team"

if ($Help) {
    Write-Host "$AppName v$AppVersion - Simple Installer" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\install.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -InstallPath <path>    Installation directory (default: $env:ProgramFiles\$AppName)"
    Write-Host "  -Uninstall             Remove the application"
    Write-Host "  -Help                  Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\install.ps1                                    # Install to default location"
    Write-Host "  .\install.ps1 -InstallPath 'C:\MyApps\$AppName'  # Install to custom location"
    Write-Host "  .\install.ps1 -Uninstall                         # Uninstall the application"
    exit 0
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function New-Shortcut {
    param([string]$TargetPath, [string]$ShortcutPath, [string]$WorkingDirectory, [string]$Description)

    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $TargetPath
    $Shortcut.WorkingDirectory = $WorkingDirectory
    $Shortcut.Description = $Description
    $Shortcut.Save()
}

function Install-Application {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "$AppName v$AppVersion - Installation" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # Check if running as administrator
    if (-not (Test-Admin)) {
        Write-Error "This installer must be run as Administrator. Please right-click and 'Run as Administrator'."
        exit 1
    }

    # Check if app files exist
    $sourcePath = Join-Path $PSScriptRoot "build\windows\x64\runner\Release"
    if (-not (Test-Path $sourcePath)) {
        Write-Error "Application files not found at: $sourcePath"
        Write-Error "Please run the build script first: .\build_installer.ps1 -BuildOnly"
        exit 1
    }

    Write-Host "Installing to: $InstallPath" -ForegroundColor Yellow

    # Create installation directory
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    }

    # Copy application files
    Write-Host "Copying application files..." -ForegroundColor Yellow
    Copy-Item "$sourcePath\*" $InstallPath -Recurse -Force

    # Create desktop shortcut
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $desktopShortcut = Join-Path $desktopPath "$AppName.lnk"
    New-Shortcut -TargetPath (Join-Path $InstallPath "auto_pdf_converter.exe") -ShortcutPath $desktopShortcut -WorkingDirectory $InstallPath -Description "$AppName v$AppVersion"

    # Create start menu shortcut
    $startMenuPath = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
    $startMenuShortcut = Join-Path $startMenuPath "$AppName.lnk"
    New-Shortcut -TargetPath (Join-Path $InstallPath "auto_pdf_converter.exe") -ShortcutPath $startMenuShortcut -WorkingDirectory $InstallPath -Description "$AppName v$AppVersion"

    # Create uninstall script
    $uninstallScript = @"
#Requires -RunAsAdministrator

Write-Host "Uninstalling $AppName..." -ForegroundColor Yellow

# Remove shortcuts
Remove-Item "$desktopShortcut" -ErrorAction SilentlyContinue
Remove-Item "$startMenuShortcut" -ErrorAction SilentlyContinue

# Remove installation directory
Remove-Item "$InstallPath" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "$AppName has been uninstalled." -ForegroundColor Green
"@

    $uninstallPath = Join-Path $InstallPath "uninstall.ps1"
    $uninstallScript | Out-File -FilePath $uninstallPath -Encoding UTF8

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Installation completed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Application installed to: $InstallPath" -ForegroundColor Green
    Write-Host "Desktop shortcut created: $desktopShortcut" -ForegroundColor Green
    Write-Host "Start Menu shortcut created: $startMenuShortcut" -ForegroundColor Green
    Write-Host ""
    Write-Host "To uninstall, run: $uninstallPath" -ForegroundColor Cyan
    Write-Host ""
}

function Uninstall-Application {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "$AppName v$AppVersion - Uninstallation" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # Check if running as administrator
    if (-not (Test-Admin)) {
        Write-Error "This uninstaller must be run as Administrator. Please right-click and 'Run as Administrator'."
        exit 1
    }

    # Remove shortcuts
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $desktopShortcut = Join-Path $desktopPath "$AppName.lnk"
    $startMenuPath = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
    $startMenuShortcut = Join-Path $startMenuPath "$AppName.lnk"

    if (Test-Path $desktopShortcut) {
        Remove-Item $desktopShortcut -Force
        Write-Host "Removed desktop shortcut" -ForegroundColor Yellow
    }

    if (Test-Path $startMenuShortcut) {
        Remove-Item $startMenuShortcut -Force
        Write-Host "Removed Start Menu shortcut" -ForegroundColor Yellow
    }

    # Remove installation directory
    if (Test-Path $InstallPath) {
        Remove-Item $InstallPath -Recurse -Force
        Write-Host "Removed installation directory: $InstallPath" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Uninstallation completed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
}

# Main execution
if ($Uninstall) {
    Uninstall-Application
} else {
    Install-Application
}