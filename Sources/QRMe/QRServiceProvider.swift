import AppKit

final class QRServiceProvider: NSObject {
    private let presenter = QRPresenter()

    @objc(showQRCode:userData:error:)
    func showQRCode(
        _ pasteboard: NSPasteboard,
        userData: String?,
        error: AutoreleasingUnsafeMutablePointer<NSString?>
    ) {
        guard let text = Self.selectedText(from: pasteboard) else {
            error.pointee = "QRMe could not read text from the current selection."
            return
        }

        DispatchQueue.main.async { [presenter] in
            presenter.show(text: text)
        }
    }

    func show(text: String) {
        presenter.show(text: text)
    }

    private static func selectedText(from pasteboard: NSPasteboard) -> String? {
        if let text = pasteboard.string(forType: .string) {
            return text
        }

        let utf8PlainText = NSPasteboard.PasteboardType("public.utf8-plain-text")
        if let text = pasteboard.string(forType: utf8PlainText) {
            return text
        }

        let plainText = NSPasteboard.PasteboardType("public.plain-text")
        if let text = pasteboard.string(forType: plainText) {
            return text
        }

        let classes: [AnyClass] = [NSString.self]
        let objects = pasteboard.readObjects(forClasses: classes)
        return objects?.compactMap { $0 as? String }.first
    }
}
