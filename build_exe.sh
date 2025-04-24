echo "Building Windows"

flutter clean
flutter pub get
flutter build windows

& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "win.iss"

echo "Building Windows Done"