#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="${QRME_INSTALL_DIR:-$HOME/Applications}"
DEST_APP="$DEST_DIR/QRMe.app"

rm -rf "$DEST_APP"

if [[ -x "/System/Library/CoreServices/pbs" ]]; then
  /System/Library/CoreServices/pbs >/dev/null 2>&1 || true
fi

echo "Removed $DEST_APP"
