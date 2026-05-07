import AppKit
import QRMeCore

private func runCommandLineModeIfNeeded() {
    let arguments = Set(CommandLine.arguments.dropFirst())

    if arguments.contains("--refresh-services") {
        NSUpdateDynamicServices()
        print("QRMe requested a Services menu refresh.")
        exit(0)
    }

    if arguments.contains("--self-test") {
        do {
            let image = try QRImageGenerator.makeImage(from: "QRMe self test")
            print("QRMe self-test generated \(Int(image.size.width))x\(Int(image.size.height)) QR image.")
            exit(0)
        } catch {
            fputs("QRMe self-test failed: \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    }
}

runCommandLineModeIfNeeded()

let app = NSApplication.shared
let delegate = AppDelegate()
let isServiceBundle = Bundle.main.bundlePath.hasSuffix(".service")

app.setActivationPolicy(isServiceBundle ? .accessory : .regular)
app.mainMenu = AppMenu.make()
app.delegate = delegate
app.run()
