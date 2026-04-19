[Setup]
AppName=Fact Save Util
AppVersion=1.0
DefaultDirName={autopf}\FactSaveUtil
DefaultGroupName=Fact Save Util
OutputDir=.\build\installer
OutputBaseFilename=FactSaveUtil_Setup
SetupIconFile=windows\runner\resources\app_icon.ico
Compression=lzma
SolidCom

Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\Fact Save Util"; Filename: "{app}\FactSaveUtil.exe"; IconFilename: "{app}\FactSaveUtil.exe"
Name: "{commondesktop}\Fact Save Util"; Filename: "{app}\FactSaveUtil.exe"; IconFilename: "{app}\FactSaveUtil.exe"; Tasks: desktopicon