import AppKit
import CoreGraphics
import Foundation
import QRCodeGenerator

public enum QRCorrectionLevel: String {
    case low = "L"
    case medium = "M"
    case quartile = "Q"
    case high = "H"

    var qrCodeECC: QRCodeECC {
        switch self {
        case .low:
            return .low
        case .medium:
            return .medium
        case .quartile:
            return .quartile
        case .high:
            return .high
        }
    }
}

public enum QRImageGenerator {
    public static func makeImage(
        from text: String,
        targetPixels: Int = 720,
        correctionLevel: QRCorrectionLevel = .medium
    ) throws -> NSImage {
        try SelectionValidator.validate(text)

        let qrCode: QRCode
        do {
            qrCode = try QRCode.encode(binary: Array(text.utf8), ecl: correctionLevel.qrCodeECC)
        } catch {
            throw QRMeError.generationFailed
        }

        let quietZoneModules = 4
        let moduleCount = qrCode.size + quietZoneModules * 2
        let modulePixels = max(1, targetPixels / moduleCount)
        let imagePixels = moduleCount * modulePixels
        let bytesPerPixel = 4
        let bytesPerRow = imagePixels * bytesPerPixel

        var pixels = [UInt8](repeating: 255, count: imagePixels * imagePixels * bytesPerPixel)

        for moduleY in 0..<qrCode.size {
            for moduleX in 0..<qrCode.size where qrCode.getModule(x: moduleX, y: moduleY) {
                drawModule(
                    x: moduleX + quietZoneModules,
                    y: moduleY + quietZoneModules,
                    modulePixels: modulePixels,
                    bytesPerPixel: bytesPerPixel,
                    bytesPerRow: bytesPerRow,
                    pixels: &pixels
                )
            }
        }

        let data = Data(pixels)
        guard
            let provider = CGDataProvider(data: data as CFData),
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
            let cgImage = CGImage(
                width: imagePixels,
                height: imagePixels,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                provider: provider,
                decode: nil,
                shouldInterpolate: false,
                intent: .defaultIntent
            )
        else {
            throw QRMeError.generationFailed
        }

        return NSImage(
            cgImage: cgImage,
            size: NSSize(width: imagePixels, height: imagePixels)
        )
    }

    private static func drawModule(
        x: Int,
        y: Int,
        modulePixels: Int,
        bytesPerPixel: Int,
        bytesPerRow: Int,
        pixels: inout [UInt8]
    ) {
        let pixelXStart = x * modulePixels
        let pixelYStart = y * modulePixels

        for pixelY in pixelYStart..<(pixelYStart + modulePixels) {
            let rowStart = pixelY * bytesPerRow

            for pixelX in pixelXStart..<(pixelXStart + modulePixels) {
                let index = rowStart + pixelX * bytesPerPixel
                pixels[index] = 0
                pixels[index + 1] = 0
                pixels[index + 2] = 0
                pixels[index + 3] = 255
            }
        }
    }
}
