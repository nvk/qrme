import AppKit
import CoreGraphics
import Vision

public enum QRCodeDecoder {
    public static func decode(from image: NSImage) throws -> [String] {
        var proposedRect = NSRect(origin: .zero, size: image.size)
        guard let cgImage = image.cgImage(
            forProposedRect: &proposedRect,
            context: nil,
            hints: nil
        ) else {
            throw QRMeError.imageUnreadable
        }

        return try decode(from: cgImage)
    }

    public static func decode(from image: CGImage) throws -> [String] {
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]

        do {
            try VNImageRequestHandler(cgImage: image).perform([request])
        } catch {
            throw QRMeError.decodingFailed
        }

        let observations = (request.results ?? []).sorted { lhs, rhs in
            let verticalDifference = lhs.boundingBox.midY - rhs.boundingBox.midY
            if abs(verticalDifference) > 0.01 {
                return verticalDifference > 0
            }
            return lhs.boundingBox.minX < rhs.boundingBox.minX
        }

        return try validatedPayloads(observations.compactMap(\.payloadStringValue))
    }

    private static func validatedPayloads(_ candidates: [String]) throws -> [String] {
        var seen = Set<String>()
        let payloads = candidates.filter { payload in
            !payload.isEmpty && seen.insert(payload).inserted
        }

        guard !payloads.isEmpty else {
            throw QRMeError.noQRCodeFound
        }

        return payloads
    }
}
