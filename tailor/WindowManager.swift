import Cocoa

class WindowManager {
    static let shared = WindowManager()
    
    private var window: NSWindow?
    
    private init() {
        // Private initializer to prevent external instantiation
    }
    
    func showContentView(contentView: NSView) {
        
        if self.window == nil {
            guard let screen = NSScreen.main else { return }
            window = NSWindow(contentRect: screen.frame,
                              styleMask: .borderless,
                              backing: .buffered,
                              defer: false)
            window?.isOpaque = false
            window?.backgroundColor = .clear
            window?.level = .floating
            window?.contentView = contentView
            window?.isReleasedWhenClosed = false
        }
        
        window?.contentView = contentView
        window?.makeKeyAndOrderFront(nil)
    }
    
    func closeWindow() {
        window?.contentView = NSView()
        window?.close()
    }
}
