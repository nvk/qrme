import AppKit

final class QRWindowController: NSWindowController {
    private let text: String
    private let image: NSImage

    init(text: String, image: NSImage) {
        self.text = text
        self.image = image

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 660),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "QRMe"
        window.contentMinSize = NSSize(width: 380, height: 500)
        window.center()
        window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        window.isReleasedWhenClosed = false

        super.init(window: window)

        window.contentView = makeContentView(text: text, image: image)
        window.delegate = self
    }

    required init?(coder: NSCoder) {
        nil
    }

    @objc private func copyText(_ sender: Any?) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    @objc private func savePNG(_ sender: Any?) {
        guard let window else {
            return
        }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "QRMe.png"

        panel.beginSheetModal(for: window) { [image] response in
            guard response == .OK, let url = panel.url else {
                return
            }

            guard
                let tiffData = image.tiffRepresentation,
                let bitmap = NSBitmapImageRep(data: tiffData),
                let pngData = bitmap.representation(using: .png, properties: [:])
            else {
                NSSound.beep()
                return
            }

            do {
                try pngData.write(to: url, options: .atomic)
            } catch {
                NSSound.beep()
            }
        }
    }

    @objc private func closeWindow(_ sender: Any?) {
        close()
    }

    private func makeContentView(text: String, image: NSImage) -> NSView {
        let root = NSView()

        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .centerX
        stackView.spacing = 16
        stackView.edgeInsets = NSEdgeInsets(top: 24, left: 24, bottom: 20, right: 24)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(stackView)

        let imageView = NSImageView(image: image)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.wantsLayer = true
        imageView.layer?.magnificationFilter = .nearest
        imageView.layer?.minificationFilter = .nearest
        stackView.addArrangedSubview(imageView)

        let preview = NSTextField(wrappingLabelWithString: Self.previewText(from: text))
        preview.alignment = .center
        preview.maximumNumberOfLines = 3
        preview.lineBreakMode = .byTruncatingMiddle
        preview.textColor = .secondaryLabelColor
        preview.font = .systemFont(ofSize: 12)
        preview.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(preview)

        let buttonStack = NSStackView()
        buttonStack.orientation = .horizontal
        buttonStack.alignment = .centerY
        buttonStack.spacing = 8
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let copyButton = NSButton(title: "Copy Text", target: self, action: #selector(copyText(_:)))
        let saveButton = NSButton(title: "Save PNG", target: self, action: #selector(savePNG(_:)))
        let closeButton = NSButton(title: "Close", target: self, action: #selector(closeWindow(_:)))

        for button in [copyButton, saveButton, closeButton] {
            button.bezelStyle = .rounded
            buttonStack.addArrangedSubview(button)
        }

        stackView.addArrangedSubview(buttonStack)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: root.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: root.bottomAnchor),

            imageView.widthAnchor.constraint(lessThanOrEqualTo: root.widthAnchor, constant: -64),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: root.heightAnchor, constant: -160),
            imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),

            preview.widthAnchor.constraint(lessThanOrEqualTo: root.widthAnchor, constant: -64)
        ])

        return root
    }

    private static func previewText(from text: String) -> String {
        let collapsed = text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")

        guard collapsed.count > 240 else {
            return collapsed
        }

        let start = collapsed.prefix(120)
        let end = collapsed.suffix(80)
        return "\(start)...\(end)"
    }
}

extension QRWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        window?.delegate = nil
    }
}
