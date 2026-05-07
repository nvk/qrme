#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE_DIR="$ROOT/build/QRMe.service"
DEST_DIR="${QRME_SERVICES_DIR:-$HOME/Library/Services}"
DEST_SERVICE="$DEST_DIR/QRMe.service"

if [[ ! -d "$SERVICE_DIR" ]]; then
  "$ROOT/scripts/build-service.sh"
fi

mkdir -p "$DEST_DIR"
rm -rf "$DEST_SERVICE"
cp -R "$SERVICE_DIR" "$DEST_SERVICE"

"$DEST_SERVICE/Contents/MacOS/QRMe" --refresh-services >/dev/null 2>&1 || true

echo "Installed $DEST_SERVICE"
echo "Select text in another app, then use Services > QRMe."
