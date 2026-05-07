import Foundation

public enum SelectionValidator {
    public static let maximumUTF8Bytes = 1_800

    public static func validate(_ text: String) throws {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw QRMeError.emptySelection
        }

        let byteCount = text.utf8.count
        guard byteCount <= maximumUTF8Bytes else {
            throw QRMeError.selectionTooLarge(
                byteCount: byteCount,
                maxBytes: maximumUTF8Bytes
            )
        }
    }
}
