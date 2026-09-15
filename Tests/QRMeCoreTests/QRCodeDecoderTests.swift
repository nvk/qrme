import AppKit
import CoreGraphics
import QRMeCore
import Vision
import XCTest

final class QRCodeDecoderTests: XCTestCase {
    func testEmptyImageReportsUnreadable() {
        XCTAssertThrowsError(try QRCodeDecoder.decode(from: NSImage())) { error in
            XCTAssertEqual(error as? QRMeError, .imageUnreadable)
        }
    }

    func testGeneratedQRCodeRoundTripsThroughDecoder() throws {
        let payload = "QRMe reads locally: https://example.com/scan?q=1"
        let image = try QRImageGenerator.makeImage(from: payload)

        let payloads = try decodeOrSkip(image)
        XCTAssertEqual(payloads, [payload])
    }

    func testImageWithoutQRCodeReportsNoCodeFound() throws {
        let image = try makeBlankImage()
        try requireVisionBarcodeDetection(using: image)

        XCTAssertThrowsError(try QRCodeDecoder.decode(from: image)) { error in
            XCTAssertEqual(error as? QRMeError, .noQRCodeFound)
        }
    }

    private func decodeOrSkip(_ image: NSImage) throws -> [String] {
        try requireVisionBarcodeDetection(using: makeBlankImage())
        return try QRCodeDecoder.decode(from: image)
    }

    private func requireVisionBarcodeDetection(using image: CGImage) throws {
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]

        do {
            try VNImageRequestHandler(cgImage: image).perform([request])
        } catch {
            throw XCTSkip("Vision barcode detection is unavailable in this test environment.")
        }
    }

    private func makeBlankImage() throws -> CGImage {
        let context = try XCTUnwrap(
            CGContext(
                data: nil,
                width: 100,
                height: 100,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        )
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
        return try XCTUnwrap(context.makeImage())
    }
}
