# QRMe

Project website: [macqr.org](https://macqr.org)

QRMe is a small macOS Services-menu app for creating and reading QR codes:

- Select text and choose `Services > Create QR Code`.
- Select an image and choose `Services > Read QR Code`.

QRMe runs locally. It does not send selected text, images, or decoded contents over the network, and it does not replace the current selection.

![QRMe window showing selected text as a QR code](docs/qrme-screenshot.png)

## Install from a Release

1. Download `QRMe.service.zip` from the latest GitHub release.
2. Unzip it.
3. Move `QRMe.service` to `~/Library/Services/`.
4. Select text or an image in another app, then choose the matching QRMe command in `Services`.

If macOS blocks the downloaded service because it is unsigned, build from source instead. Source-built services are the recommended path for now.

## Build the Service Bundle

```sh
./scripts/build-service.sh
```

The service bundle is created at `build/QRMe.service`.

## Install for the Current User

```sh
./scripts/install-service.sh
```

This copies the service to `~/Library/Services/QRMe.service` and asks macOS to refresh the Services menu.

To uninstall:

```sh
./scripts/uninstall-service.sh
```

## Create a QR Code

1. Select text in an app such as TextEdit, Safari, Notes, or Mail.
2. Right-click the selected text.
3. Choose `Services > Create QR Code`.
4. Scan the QR code from the QRMe window.

## Read a QR Code

1. Select a QR code image in Finder or another app.
2. Right-click the image.
3. Choose `Services > Read QR Code`.
4. Copy the decoded contents, or explicitly open them when they are an HTTP or HTTPS link.

When QRMe is installed as a regular app, `Open QR Code…` also lets you choose an image file directly.

macOS and the host app decide whether a Service appears directly in the contextual menu or under `Services`.

## Development Checks

```sh
swift build --disable-sandbox
swift test --disable-sandbox
swift run --disable-sandbox QRMe --self-test
./scripts/package-release.sh
```

## Notes

- Very large text selections are rejected because they produce QR codes that are difficult or impossible to scan reliably.
- QR decoding uses Apple's on-device Vision framework.
- QR encoding uses the MIT-licensed `fwcd/swift-qrcode-generator` package, derived from Project Nayuki's QR Code generator.

## License

MIT. See `LICENSE`.
