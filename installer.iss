[Setup]
AppName=Auto PDF Converter
AppVersion=1.0.0
DefaultDirName={pf}\Auto PDF Converter
DefaultGroupName=Auto PDF Converter
OutputDir=installer
OutputBaseFilename=AutoPDFConverter_1.0.0_Installer
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Auto PDF Converter"; Filename: "{app}\auto_pdf_converter.exe"
Name: "{commondesktop}\Auto PDF Converter"; Filename: "{app}\auto_pdf_converter.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\auto_pdf_converter.exe"; Description: "{cm:LaunchProgram,Auto PDF Converter}"; Flags: nowait postinstall skipifsilent

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Optional: Add any post-installation code here
  end;
end;