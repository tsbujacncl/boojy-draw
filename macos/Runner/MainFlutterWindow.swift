import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // Configure window for digital painting app
    // Set minimum window size (1024x768)
    self.minSize = NSSize(width: 1024, height: 768)

    // Set initial window size if not set (1400x900)
    if self.frame.width < 1400 || self.frame.height < 900 {
      let screenFrame = NSScreen.main?.visibleFrame ?? NSRect.zero
      let width: CGFloat = 1400
      let height: CGFloat = 900
      let x = (screenFrame.width - width) / 2
      let y = (screenFrame.height - height) / 2
      self.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
    }

    // Set window title
    self.title = "Boojy Draw"

    // Use standard macOS window style (not full-size content)
    // This prevents content from being cut off by the title bar
  }
}
