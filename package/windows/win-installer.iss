[Setup]
AppName=clavis
AppVersion={#versionStrict}
VersionInfoVersion={#versionStrict}
DefaultDirName={autopf64}\clavis
DefaultGroupName=clavis
OutputBaseFilename=install_clavis_{#version}
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
UninstallDisplayName=clavis

[Files]
Source: "{#buildDir}\clavis.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#buildDir}\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#buildDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs

[Tasks]
Name: "desktop"; Description: "Create Desktop Icon"; GroupDescription: "Additional Tasks"; Flags: unchecked
Name: "startmenu"; Description: "Create Start Menu Icon"; GroupDescription: "Additional Tasks"; Flags: unchecked

[Icons]
Name: "{commondesktop}\clavis"; Filename: "{app}\clavis.exe"; WorkingDir: "{app}"; Tasks: desktop
Name: "{group}\clavis"; Filename: "{app}\clavis.exe"; WorkingDir: "{app}"; Tasks: startmenu
Name: "{group}\Uninstall clavis"; Filename: "{uninstallexe}"; Tasks: startmenu

[Run]
Filename: "{app}\clavis.exe"; Description: "Start clavis"; Flags: nowait postinstall skipifsilent
