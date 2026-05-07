import AppKit
import QRMeCore

final class QRPresenter {
    private var windowController: QRWindowController?

    func show(text: String) {
        do {
            let image = try QRImageGenerator.makeImage(from: text)
            let controller = QRWindowController(text: text, image: image)
            windowController = controller
            controller.showWindow(nil)
            controller.window?.makeKeyAndOrderFront(nil)
            activateApp()
        } catch {
            showError(error.localizedDescription)
        }
    }

    private func showError(_ message: String) {
        activateApp()

        let alert = NSAlert()
        alert.messageText = "QRMe"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }

    private func activateApp() {
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
