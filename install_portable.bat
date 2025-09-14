@echo off
echo ========================================
echo Auto PDF Converter - Portable Installer
echo ========================================
echo.

echo This will create a portable installation in the current directory.
echo The app can be run directly without installation.
echo.

set "INSTALL_DIR=%~dp0Auto PDF Converter"

echo Installing to: %INSTALL_DIR%
echo.

if exist "%INSTALL_DIR%" (
    echo Removing existing installation...
    rmdir /s /q "%INSTALL_DIR%"
)

echo Copying application files...
xcopy "build\windows\x64\runner\Release\*" "%INSTALL_DIR%\" /e /i /h /y >nul

echo.
echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\Auto PDF Converter.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\auto_pdf_converter.exe'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'Auto PDF Converter v1.0.0'; $Shortcut.Save()"

echo.
echo ========================================
echo Installation completed successfully!
echo ========================================
echo.
echo Application installed to: %INSTALL_DIR%
echo Desktop shortcut created
echo.
echo To run the app, double-click: auto_pdf_converter.exe
echo.
echo To uninstall, simply delete the "%INSTALL_DIR%" folder
echo and remove the desktop shortcut.
echo.
pause