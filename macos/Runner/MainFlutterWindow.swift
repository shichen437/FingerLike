import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        self.minSize = NSSize(width: 600, height: 450)
        // 设置窗口样式
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.styleMask.insert(.fullSizeContentView)
        
        // 设置窗口行为
        self.isReleasedWhenClosed = false
        self.collectionBehavior = [.managed, .fullScreenPrimary] // 允许窗口被管理
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        
        super.awakeFromNib()
    }
    
    override func close() {
        self.orderOut(nil) // 隐藏窗口而不是关闭
    }
    
    // 添加显示窗口的方法
    func showWindow() {
        self.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
