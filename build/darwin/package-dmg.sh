#!/bin/bash
# Package a Wails macOS .app into a distributable .zip (bundle-safe) and
# a .dmg installer with an /Applications shortcut.
# Usage: bash build/darwin/package-dmg.sh [path/to/app.app]
set -euo pipefail

APP_PATH="${1:-build/bin/Mocha.app}"
# Display name (bundle) differs from the binary Wails emits.
BIN_NAME="${BIN_NAME:-mocha-desktop}"
APP_NAME="$(basename "$APP_PATH" .app)"
BIN_DIR="$(dirname "$APP_PATH")"
BIN_PATH="$APP_PATH/Contents/MacOS/$BIN_NAME"
ZIP_PATH="$BIN_DIR/$APP_NAME.app.zip"
DMG_PATH="$BIN_DIR/$APP_NAME.dmg"
VOLUME_NAME="Mocha"

if [ ! -d "$APP_PATH" ]; then
  echo "error: .app not found at $APP_PATH (run 'wails build' first)" >&2
  exit 1
fi
if [ ! -f "$BIN_PATH" ]; then
  echo "error: binary not found at $BIN_PATH" >&2
  exit 1
fi

# Executable bit is lost by some upload/extract flows; restore it.
chmod +x "$BIN_PATH"
# Strip quarantine flags inherited from CI checkouts/downloads.
xattr -cr "$APP_PATH" || true
# Ad-hoc sign so Gatekeeper treats the bundle as one unit. Replace `-`
# with a Developer ID identity + notarization for public distribution.
codesign --sign - --force --deep "$APP_PATH"
codesign --verify --strict "$APP_PATH"

# ditto preserves bundle bits/resource forks; plain zip/upload-artifact flattens .app into bare Contents/MacOS dirs.
rm -f "$ZIP_PATH"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

TMP_DIR="$(mktemp -d /tmp/mocha-dmg.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT
cp -R "$APP_PATH" "$TMP_DIR/"
ln -s /Applications "$TMP_DIR/Applications"
rm -f "$DMG_PATH"
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$TMP_DIR" -ov -format UDZO "$DMG_PATH" >/dev/null

echo "app: $APP_PATH"
echo "zip: $ZIP_PATH"
echo "dmg: $DMG_PATH"
