#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="${QRME_SERVICES_DIR:-$HOME/Library/Services}"
DEST_SERVICE="$DEST_DIR/QRMe.service"

rm -rf "$DEST_SERVICE"

if [[ -x "/System/Library/CoreServices/pbs" ]]; then
  /System/Library/CoreServices/pbs -update >/dev/null 2>&1 || /System/Library/CoreServices/pbs >/dev/null 2>&1 || true
fi

echo "Removed $DEST_SERVICE"
