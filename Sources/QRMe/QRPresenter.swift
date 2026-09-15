import AppKit
import QRMeCore

final class QRPresenter {
    private var qrWindowController: QRWindowController?
    private var resultWindowController: QRResultWindowController?

    func show(text: String) {
        do {
            let image = try QRImageGenerator.makeImage(from: text)
            let controller = QRWindowController(text: text, image: image)
            qrWindowController = controller
            present(controller)
        } catch {
            showError(error.localizedDescription)
        }
    }

    func read(image: NSImage) {
        do {
            let payloads = try QRCodeDecoder.decode(from: image)
            let controller = QRResultWindowController(payloads: payloads)
            resultWindowController = controller
            present(controller)
        } catch {
            showError(error.localizedDescription)
        }
    }

    func read(fileURL: URL) {
        guard let image = NSImage(contentsOf: fileURL) else {
            showError(QRMeError.imageUnreadable.localizedDescription)
            return
        }
        read(image: image)
    }

    private func present(_ controller: NSWindowController) {
        controller.showWindow(nil)
        controller.window?.makeKeyAndOrderFront(nil)
        activateApp()
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
