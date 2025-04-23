#define MyAppName "FingerLike"
#define MyAppVersion "0.0.3"
#define MyAppPublisher "shichen437"
#define MyAppExeName "finger_like.exe"

[Setup]
AppId={{{{A6C71002-3F82-47E1-AC34-9876C3902311}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=build\windows\installer
OutputBaseFilename=FingerLike
Compression=lzma
SolidCompression=yes
WizardStyle=modern
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
CreateUninstallRegKey=yes
UninstallFilesDir={app}

[UninstallDelete]
Type: files; Name: "{app}\*.*"
Type: dirifempty; Name: "{app}"

[Messages]
UninstallMenuEntry=卸载 %1
ConfirmUninstall=您确定要完全删除 %1 及其所有组件吗？

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{group}\卸载 {#MyAppName}"; Filename: "{uninstallexe}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent