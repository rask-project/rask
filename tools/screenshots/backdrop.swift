// A full-screen, click-through background for the display with the menu bar:
// soft colour blobs on a dark gradient, so the examples' blur and glass show
// up in screenshots and nothing else on the desktop does.
//
// Usage: backdrop [light]        (runs until killed)
import Cocoa

final class BlobsView: NSView {
    let light: Bool

    init(frame: NSRect, light: Bool) {
        self.light = light
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { nil }

    override func draw(_ dirtyRect: NSRect) {
        let base = light
            ? NSGradient(starting: NSColor(srgbRed: 0.93, green: 0.94, blue: 0.97, alpha: 1),
                         ending: NSColor(srgbRed: 0.80, green: 0.84, blue: 0.92, alpha: 1))!
            : NSGradient(starting: NSColor(srgbRed: 0.16, green: 0.18, blue: 0.27, alpha: 1),
                         ending: NSColor(srgbRed: 0.06, green: 0.07, blue: 0.11, alpha: 1))!
        base.draw(in: bounds, angle: -60)
        // (x, y, radius) as fractions of the screen, and a colour.
        let blobs: [(CGFloat, CGFloat, CGFloat, NSColor)] = [
            (0.22, 0.62, 0.30, NSColor(srgbRed: 1.00, green: 0.42, blue: 0.21, alpha: 1)),
            (0.46, 0.30, 0.26, NSColor(srgbRed: 0.18, green: 0.55, blue: 1.00, alpha: 1)),
            (0.66, 0.70, 0.28, NSColor(srgbRed: 0.62, green: 0.30, blue: 0.95, alpha: 1)),
            (0.84, 0.32, 0.22, NSColor(srgbRed: 0.10, green: 0.80, blue: 0.62, alpha: 1)),
        ]
        for (x, y, r, color) in blobs {
            let center = NSPoint(x: bounds.width * x, y: bounds.height * y)
            let radius = bounds.width * r
            NSGradient(starting: color.withAlphaComponent(light ? 0.55 : 0.75),
                       ending: color.withAlphaComponent(0))!
                .draw(fromCenter: center, radius: 0, toCenter: center, radius: radius, options: [])
        }
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
// screens[0] is the display with the menu bar, whose top-left is (0, 0) in the
// global coordinates screencapture -R and CGWindowList use.
let frame = NSScreen.screens[0].frame
let window = NSWindow(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false)
window.contentView = BlobsView(frame: frame, light: CommandLine.arguments.dropFirst().first == "light")
window.level = .normal
window.isOpaque = true
window.ignoresMouseEvents = true
window.orderFrontRegardless()
app.run()
