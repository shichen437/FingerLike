import Cocoa
import FlutterMacOS
import Foundation

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        // 修复控制器获取方式
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
                
            case "click":
                guard let args = call.arguments as? [String: Any],
                      let count = args["count"] as? Int else {
                    result(FlutterError(code: "INVALID_ARG", message: "无效参数", details: nil))
                    return
                }
                
                guard MouseClickHandler.checkAccessibilityPermission() else {
                    result(FlutterError(code: "NO_PERMISSION", 
                           message: "需要辅助功能权限", details: nil))
                    return
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    MouseClickHandler.performMouseClick(count: count)
                    result(nil)
                }
                
            case "clickAt":  // 原生端已正确实现的方法名称
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
                    CGAssociateMouseAndMouseCursorPosition(1)  // 使用 1 替代 Int32(true)
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
        
        super.applicationDidFinishLaunching(notification) // 必须调用父类方法
        
        // 在使用 MouseClickHandler 前添加内联定义
        // 修复 MouseClickHandler 内联定义中的 post 方法调用
        class MouseClickHandler {
            static func checkAccessibilityPermission() -> Bool {
                let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
                return AXIsProcessTrustedWithOptions(options as CFDictionary)
            }
            
            static func getCurrentPosition() -> [String: Any] {
                let mouseLocation = NSEvent.mouseLocation
                let screenFrame = NSScreen.main?.frame ?? .zero
                
                // 转换坐标系（macOS 使用左下角为原点，我们需要转换为左上角为原点）
                let y = screenFrame.height - mouseLocation.y
                
                return [
                    "x": mouseLocation.x,
                    "y": y
                ]
            }
            
            static func performMouseClick(count: Int) {
                // 创建鼠标按下事件
                let eventDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                                      mouseCursorPosition: .zero, mouseButton: .left)
                // 创建鼠标抬起事件
                let eventUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                                    mouseCursorPosition: .zero, mouseButton: .left)
                
                // 循环执行点击
                for _ in 0..<count {
                    eventDown?.post(tap: .cghidEventTap)  // 修复：添加 tap: 参数标签
                    eventUp?.post(tap: .cghidEventTap)    // 修复：添加 tap: 参数标签
                    Thread.sleep(forTimeInterval: 0.001) // 保持点击间隔
                }
            }
            
            static func performMouseClickAt(x: Double, y: Double) {
                let position = CGPoint(x: x, y: y)
                
                // 创建鼠标按下事件
                let eventDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                                      mouseCursorPosition: position, mouseButton: .left)
                // 创建鼠标抬起事件
                let eventUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                                    mouseCursorPosition: position, mouseButton: .left)
                
                eventDown?.post(tap: .cghidEventTap)
                eventUp?.post(tap: .cghidEventTap)
                Thread.sleep(forTimeInterval: 0.001)
            }
        }
    }
}
