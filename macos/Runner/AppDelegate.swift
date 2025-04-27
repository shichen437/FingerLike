import Cocoa
import FlutterMacOS
import Foundation

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func toggleWindow() {
        if let window = NSApp.windows.first {
            if window.isVisible {
                window.orderOut(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
            fatalError("无法获取 Flutter 控制器")
        }
        
        let channel = FlutterMethodChannel(
            name: "mouse_clicker",
            binaryMessenger: controller.engine.binaryMessenger
        )
        
        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "getCurrentPosition":
                let position = MouseClickHandler.getCurrentPosition()
                result(position)
                
            case "clickAt":
                guard let args = call.arguments as? [String: Any],
                      let x = args["x"] as? Double,
                      let y = args["y"] as? Double else {
                    result(FlutterError(code: "INVALID_ARG", message: "无效参数", details: nil))
                    return
                }
                
                guard MouseClickHandler.checkAccessibilityPermission() else {
                    result(FlutterError(code: "NO_PERMISSION", 
                           message: "需要辅助功能权限", details: nil))
                    return
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    MouseClickHandler.performMouseClickAt(x: x, y: y)
                    result(nil)
                }
                
            case "moveMouse":
                guard let args = call.arguments as? [String: Any],
                      let x = args["x"] as? Double,
                      let y = args["y"] as? Double else {
                    result(FlutterError(code: "INVALID_ARG", message: "无效参数", details: nil))
                    return
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    let point = CGPoint(x: x, y: y)
                    CGWarpMouseCursorPosition(point)
                    CGAssociateMouseAndMouseCursorPosition(1)
                    result(nil)
                }
            
            case "getScreenFrame":
                if let screen = NSScreen.main {
                    result([
                        "width": screen.frame.width,
                        "height": screen.frame.height
                    ])
                } else {
                    result(FlutterError(code: "NO_SCREEN", message: "无法获取屏幕信息", details: nil))
                }
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        super.applicationDidFinishLaunching(notification)
    }
    
    // 处理 Dock 图标点击
    override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showMainWindow()
        }
        return true
    }
    
    @objc func showMainWindow() {
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

public class MouseClickHandler: NSObject {
    public static func checkAccessibilityPermission() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    public static func getCurrentPosition() -> [String: CGFloat] {
        let mouseLocation = NSEvent.mouseLocation
        let screenFrame = NSScreen.main?.frame ?? .zero
        
        // 转换坐标系
        let y = screenFrame.height - mouseLocation.y
        
        return [
            "x": mouseLocation.x,
            "y": y
        ]
    }
    
    public static func performMouseClickAt(x: Double, y: Double) {
        let position = CGPoint(x: x, y: y)
        let eventDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                              mouseCursorPosition: position, mouseButton: .left)
        let eventUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                            mouseCursorPosition: position, mouseButton: .left)
        
        eventDown?.post(tap: .cghidEventTap)
        Thread.sleep(forTimeInterval: TimeInterval(40 + arc4random_uniform(15)) / 1000.0)
        eventUp?.post(tap: .cghidEventTap)
        Thread.sleep(forTimeInterval: 0.005)
    }
}
