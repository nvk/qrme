#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT/build/QRMe.app"
DEST_DIR="${QRME_INSTALL_DIR:-$HOME/Applications}"
DEST_APP="$DEST_DIR/QRMe.app"

if [[ ! -d "$APP_DIR" ]]; then
  "$ROOT/scripts/build-app.sh"
fi

mkdir -p "$DEST_DIR"
rm -rf "$DEST_APP"
cp -R "$APP_DIR" "$DEST_APP"

"$DEST_APP/Contents/MacOS/QRMe" --refresh-services >/dev/null 2>&1 || true

echo "Installed $DEST_APP"
echo "Select text in another app, then use Services > QRMe."
