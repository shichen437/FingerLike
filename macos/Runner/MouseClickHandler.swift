import Cocoa
import FlutterMacOS

public class MouseClickHandler: NSObject {
    public static func checkAccessibilityPermission() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    public static func getCurrentPosition() -> [String: CGFloat] {
        let mouseLocation = NSEvent.mouseLocation
        let screenFrame = NSScreen.main?.frame ?? .zero
        
        // 转换坐标系（macOS 使用左下角为原点，我们需要转换为左上角为原点）
        let y = screenFrame.height - mouseLocation.y
        
        return [
            "x": mouseLocation.x,
            "y": y
        ]
    }
    
    public static func performMouseClick(count: Int) {
        // 创建鼠标按下事件
        let eventDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                              mouseCursorPosition: .zero, mouseButton: .left)
        // 创建鼠标抬起事件
        let eventUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                            mouseCursorPosition: .zero, mouseButton: .left)
        
        // 循环执行点击
        for _ in 0..<count {
            eventDown?.post(.cghidEventTap)
            eventUp?.post(.cghidEventTap)
            Thread.sleep(forTimeInterval: 0.001) // 保持点击间隔
        }
    }
}