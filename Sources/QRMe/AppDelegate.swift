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
}
