import 'package:flutter/services.dart';

class MouseClicker {
  static const _channel = MethodChannel('mouse_clicker');

  static Future<void> click({int count = 1}) async {
    try {
      await _channel.invokeMethod('click', {'count': count});
    } on PlatformException catch (e) {
      print("点击失败: ${e.message}");
    }
  }
}