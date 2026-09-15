import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let serviceProvider = QRServiceProvider()
    private var isServiceBundle: Bool {
        Bundle.main.bundlePath.hasSuffix(".service")
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.servicesProvider = serviceProvider
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        isServiceBundle
    }

    @objc func showSampleQRCode(_ sender: Any?) {
        serviceProvider.show(text: "https://example.com")
    }

    @objc func openQRCode(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.message = "Choose an image containing a QR code."
        panel.prompt = "Read"

        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }

        serviceProvider.read(fileURL: url)
    }
}
