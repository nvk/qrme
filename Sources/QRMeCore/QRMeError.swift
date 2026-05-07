import Foundation

public enum QRMeError: LocalizedError, Equatable {
    case emptySelection
    case selectionTooLarge(byteCount: Int, maxBytes: Int)
    case generationFailed

    public var errorDescription: String? {
        switch self {
        case .emptySelection:
            return "Select some text before running QRMe."
        case let .selectionTooLarge(byteCount, maxBytes):
            return "The selected text is too long for a reliable QR code (\(byteCount) bytes). Try \(maxBytes) bytes or fewer."
        case .generationFailed:
            return "QRMe could not generate a QR code for this selection."
        }
    }
}
