import AppKit
import UniformTypeIdentifiers

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

    @objc(readQRCode:userData:error:)
    func readQRCode(
        _ pasteboard: NSPasteboard,
        userData: String?,
        error: AutoreleasingUnsafeMutablePointer<NSString?>
    ) {
        guard let image = Self.selectedImage(from: pasteboard) else {
            error.pointee = "QRMe could not read an image from the current selection."
            return
        }

        DispatchQueue.main.async { [presenter] in
            presenter.read(image: image)
        }
    }

    func read(fileURL: URL) {
        presenter.read(fileURL: fileURL)
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

    private static func selectedImage(from pasteboard: NSPasteboard) -> NSImage? {
        if let image = NSImage(pasteboard: pasteboard) {
            return image
        }

        let options: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: true,
            .urlReadingContentsConformToTypes: [UTType.image.identifier]
        ]
        if
            let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: options) as? [URL],
            let url = urls.first,
            let image = NSImage(contentsOf: url)
        {
            return image
        }

        for type in [NSPasteboard.PasteboardType.png, .tiff] {
            if let data = pasteboard.data(forType: type), let image = NSImage(data: data) {
                return image
            }
        }

        return nil
    }
}
