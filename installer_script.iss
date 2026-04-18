[Setup]
AppName=Fact Save Util
AppVersion=1.0
DefaultDirName={autopf}\FactSaveUtil
DefaultGroupName=Fact Save Util
OutputDir=.\build\installer
OutputBaseFilename=FactSaveUtil_Setup
; --- ADD THIS LINE ---
SetupIconFile=windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
; Ensure the shortcut points to the icon inside the EXE
Name: "{group}\Fact Save Util"; Filename: "{app}\fact_save_util.exe"; IconFilename: "{app}\fact_save_util.exe"
Name: "{commondesktop}\Fact Save Util"; Filename: "{app}\fact_save_util.exe"; IconFilename: "{app}\fact_save_util.exe"; Tasks: desktopicon