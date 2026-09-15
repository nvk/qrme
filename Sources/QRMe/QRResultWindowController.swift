import AppKit

final class QRResultWindowController: NSWindowController {
    private let payloads: [String]
    private weak var copyButton: NSButton?
    private var resetCopyButtonWorkItem: DispatchWorkItem?

    init(payloads: [String]) {
        precondition(!payloads.isEmpty)
        self.payloads = payloads

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 340),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = payloads.count == 1 ? "QR Code Contents" : "QR Code Contents (\(payloads.count))"
        window.contentMinSize = NSSize(width: 380, height: 220)
        window.center()
        window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        window.isReleasedWhenClosed = false

        super.init(window: window)

        window.contentView = makeContentView()
        window.delegate = self
    }

    required init?(coder: NSCoder) {
        nil
    }

    @objc private func copyContents(_ sender: Any?) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(payloads.joined(separator: "\n\n"), forType: .string)

        resetCopyButtonWorkItem?.cancel()
        copyButton?.title = "Copied"

        let workItem = DispatchWorkItem { [weak self] in
            self?.copyButton?.title = self?.payloads.count == 1 ? "Copy" : "Copy All"
        }
        resetCopyButtonWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: workItem)
    }

    @objc private func openLink(_ sender: Any?) {
        guard let url = webURL else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    @objc private func closeWindow(_ sender: Any?) {
        close()
    }

    private func makeContentView() -> NSView {
        let root = NSView()

        let scrollView = NSScrollView()
        scrollView.borderType = .bezelBorder
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 512, height: 240))
        textView.isEditable = false
        textView.isSelectable = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(
            width: 512,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.drawsBackground = true
        textView.backgroundColor = .textBackgroundColor
        textView.textColor = .textColor
        textView.font = .systemFont(ofSize: 14)
        textView.textContainerInset = NSSize(width: 10, height: 10)
        textView.string = displayedContents
        textView.setAccessibilityLabel("QR code contents")
        scrollView.documentView = textView

        let buttonStack = NSStackView()
        buttonStack.orientation = .horizontal
        buttonStack.alignment = .centerY
        buttonStack.spacing = 8
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let closeButton = NSButton(title: "Close", target: self, action: #selector(closeWindow(_:)))
        closeButton.bezelStyle = .rounded
        closeButton.keyEquivalent = "\u{1b}"
        buttonStack.addArrangedSubview(closeButton)

        if webURL != nil {
            let openButton = NSButton(title: "Open Link", target: self, action: #selector(openLink(_:)))
            openButton.bezelStyle = .rounded
            buttonStack.addArrangedSubview(openButton)
        }

        let copyTitle = payloads.count == 1 ? "Copy" : "Copy All"
        let copyButton = NSButton(title: copyTitle, target: self, action: #selector(copyContents(_:)))
        copyButton.bezelStyle = .rounded
        copyButton.keyEquivalent = "\r"
        buttonStack.addArrangedSubview(copyButton)
        self.copyButton = copyButton

        root.addSubview(scrollView)
        root.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -24),
            scrollView.topAnchor.constraint(equalTo: root.topAnchor, constant: 24),
            scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -16),

            buttonStack.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -24),
            buttonStack.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -20)
        ])

        return root
    }

    private var displayedContents: String {
        guard payloads.count > 1 else {
            return payloads[0]
        }

        return payloads.enumerated().map { index, payload in
            "QR code \(index + 1)\n\(payload)"
        }.joined(separator: "\n\n")
    }

    private var webURL: URL? {
        guard
            payloads.count == 1,
            let url = URL(string: payloads[0]),
            let scheme = url.scheme?.lowercased(),
            (scheme == "http" || scheme == "https"),
            url.host != nil
        else {
            return nil
        }
        return url
    }
}

extension QRResultWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        resetCopyButtonWorkItem?.cancel()
        window?.delegate = nil
    }
}
