#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${CONFIG:-debug}"
APP_DIR="$ROOT/build/QRMe.app"

case "$CONFIG" in
  debug|release) ;;
  *)
    echo "CONFIG must be debug or release" >&2
    exit 2
    ;;
esac

swift build --disable-sandbox -c "$CONFIG" --package-path "$ROOT"

BINARY="$ROOT/.build/$CONFIG/QRMe"
if [[ ! -x "$BINARY" ]]; then
  echo "Expected executable not found at $BINARY" >&2
  exit 1
fi

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

cp "$BINARY" "$APP_DIR/Contents/MacOS/QRMe"
cp "$ROOT/AppBundle/Info.plist" "$APP_DIR/Contents/Info.plist"
printf 'APPL????' > "$APP_DIR/Contents/PkgInfo"
chmod +x "$APP_DIR/Contents/MacOS/QRMe"

plutil -lint "$APP_DIR/Contents/Info.plist"

echo "Built $APP_DIR"
