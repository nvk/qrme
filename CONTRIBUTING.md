# Contributing

QRMe is a small macOS Swift/AppKit project. Keep changes focused and test the Services-menu workflow in a real macOS app before opening a pull request.

## Development

```sh
swift build --disable-sandbox
swift test --disable-sandbox
swift run --disable-sandbox QRMe --self-test
./scripts/build-service.sh
```

## Manual Test

1. Install the service with `./scripts/install-service.sh`.
2. Select text in TextEdit.
3. Choose `TextEdit > Services > Create QR Code` or right-click and choose `Services > Create QR Code`.
4. Confirm a QR window opens and scans from a phone.
5. Select a QR image in Finder and choose `Services > Read QR Code`.
6. Confirm its contents appear and can be copied.

## Release

```sh
./scripts/package-release.sh
```

This creates `build/QRMe.service.zip` and `build/QRMe.service.zip.sha256`.
