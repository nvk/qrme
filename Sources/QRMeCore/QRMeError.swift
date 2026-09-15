import Foundation

public enum QRMeError: LocalizedError, Equatable {
    case emptySelection
    case selectionTooLarge(byteCount: Int, maxBytes: Int)
    case generationFailed
    case imageUnreadable
    case noQRCodeFound
    case decodingFailed

    public var errorDescription: String? {
        switch self {
        case .emptySelection:
            return "Select some text before running QRMe."
        case let .selectionTooLarge(byteCount, maxBytes):
            return "The selected text is too long for a reliable QR code (\(byteCount) bytes). Try \(maxBytes) bytes or fewer."
        case .generationFailed:
            return "QRMe could not generate a QR code for this selection."
        case .imageUnreadable:
            return "QRMe could not read that image. Try a PNG, JPEG, HEIC, GIF, or TIFF file."
        case .noQRCodeFound:
            return "No readable QR code was found in the image. Try a sharper image with the entire code visible."
        case .decodingFailed:
            return "QRMe could not scan this image. Try another copy of the image."
        }
    }
}
