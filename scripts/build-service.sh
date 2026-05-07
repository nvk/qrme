#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${CONFIG:-debug}"
SERVICE_DIR="$ROOT/build/QRMe.service"

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

rm -rf "$SERVICE_DIR"
mkdir -p "$SERVICE_DIR/Contents/MacOS" "$SERVICE_DIR/Contents/Resources"

cp "$BINARY" "$SERVICE_DIR/Contents/MacOS/QRMe"
cp "$ROOT/AppBundle/ServiceInfo.plist" "$SERVICE_DIR/Contents/Info.plist"
printf 'APPL????' > "$SERVICE_DIR/Contents/PkgInfo"
chmod +x "$SERVICE_DIR/Contents/MacOS/QRMe"

plutil -lint "$SERVICE_DIR/Contents/Info.plist"

echo "Built $SERVICE_DIR"
