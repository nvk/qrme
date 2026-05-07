# Contributing

QRMe is a small macOS Swift/AppKit project. Keep changes focused and test the Services-menu workflow in a real macOS app before opening a pull request.

## Development

```sh
swift build --disable-sandbox
swift run --disable-sandbox QRMe --self-test
./scripts/build-service.sh
```

## Manual Test

1. Install the service with `./scripts/install-service.sh`.
2. Select text in TextEdit.
3. Choose `TextEdit > Services > QRMe` or right-click and choose `Services > QRMe`.
4. Confirm a QR window opens and scans from a phone.

## Release

```sh
./scripts/package-release.sh
```

This creates `build/QRMe.service.zip` and `build/QRMe.service.zip.sha256`.
