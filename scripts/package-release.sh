#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE_DIR="$ROOT/build/QRMe.service"
ZIP_PATH="$ROOT/build/QRMe.service.zip"
SHA_PATH="$ZIP_PATH.sha256"

CONFIG=release "$ROOT/scripts/build-service.sh"

rm -f "$ZIP_PATH" "$SHA_PATH"

if command -v ditto >/dev/null 2>&1; then
  ditto -c -k --sequesterRsrc --keepParent "$SERVICE_DIR" "$ZIP_PATH"
else
  (
    cd "$ROOT/build"
    zip -qry "$(basename "$ZIP_PATH")" "QRMe.service"
  )
fi

(
  cd "$ROOT/build"
  shasum -a 256 "$(basename "$ZIP_PATH")" > "$(basename "$SHA_PATH")"
)

echo "Packaged $ZIP_PATH"
echo "Wrote $SHA_PATH"
