#!/bin/bash
APP_NAME="FingerLike"
DMG_NAME="${APP_NAME}.dmg"
APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"

# 确保应用已经构建
flutter build macos --release

# 创建 DMG
create-dmg \
  --volname "$APP_NAME" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "$APP_NAME.app" 200 190 \
  --hide-extension "$APP_NAME.app" \
  --app-drop-link 600 185 \
  "$DMG_NAME" \
  "$APP_PATH"