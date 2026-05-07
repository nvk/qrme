// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "QRMe",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "QRMe", targets: ["QRMe"])
    ],
    dependencies: [
        .package(url: "https://github.com/fwcd/swift-qrcode-generator.git", exact: "2.0.2")
    ],
    targets: [
        .target(
            name: "QRMeCore",
            dependencies: [
                .product(name: "QRCodeGenerator", package: "swift-qrcode-generator")
            ]
        ),
        .executableTarget(
            name: "QRMe",
            dependencies: ["QRMeCore"]
        )
    ]
)
