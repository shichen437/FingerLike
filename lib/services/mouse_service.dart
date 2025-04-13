import 'package:flutter/services.dart';

class MouseService {
  static const _channel = MethodChannel('mouse_clicker');

  static Future<Point> getCurrentPosition() async {
    try {
      final result = await _channel.invokeMethod('getCurrentPosition');
      return Point(result['x'] as double, result['y'] as double);
    } on PlatformException catch (e) {
      throw ClickException('获取鼠标位置失败: ${e.message}');
    }
  }

  static Future<void> click() async {
    try {
      await _channel.invokeMethod('click', {'count': 1});
    } on PlatformException catch (e) {
      throw ClickException('点击失败: ${e.message}');
    }
  }

  static Future<void> clickAt(Point position) async {
    try {
      await _channel.invokeMethod('clickAt', {
        // 保持与原生端一致的方法名称
        'x': position.x,
        'y': position.y,
      });
    } on PlatformException catch (e) {
      throw ClickException('点击失败: ${e.message}');
    }
  }
}

class ClickException implements Exception {
  final String message;
  ClickException(this.message);
}

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
}
