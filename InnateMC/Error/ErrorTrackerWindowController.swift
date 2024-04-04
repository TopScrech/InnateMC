import SwiftUI

class ErrorTrackerWindowController: NSWindowController {
    override func windowDidLoad() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
    
    convenience init() {
        let window: NSWindow = .init(contentRect: NSRect(x: 0, y: 0, width: 400, height: 600), styleMask: [.titled, .resizable, .closable], backing: .buffered, defer: false)
        window.contentView = NSHostingView(rootView: ErrorTrackerView(errorTracker: .instance))
        window.title = NSLocalizedString("errors", comment: "Errors")
        
        self.init(window: window)
    }
}
