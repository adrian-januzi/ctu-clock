#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

echo "Building release binary..."
swift build -c release

APP_NAME="CTU Clock"
APP_DIR="$HOME/Applications/${APP_NAME}.app"
CONTENTS="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS/MacOS"
RESOURCES_DIR="$CONTENTS/Resources"

echo "Assembling ${APP_NAME}.app in ~/Applications..."
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp .build/release/CTUClock "$MACOS_DIR/CTUClock"

# Copy the SPM resource bundle contents (tick.mp3) into Resources
if [ -d .build/release/CTUClock_CTUClock.bundle ]; then
  cp -R .build/release/CTUClock_CTUClock.bundle "$RESOURCES_DIR/"
fi

cat > "$CONTENTS/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.ctuclock</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>CTUClock</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "Ad-hoc code signing..."
codesign --force --deep --sign - "$APP_DIR"

echo "Done. Installed at: $APP_DIR"
