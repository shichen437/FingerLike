import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class MouseService {
  static const _channel = MethodChannel('mouse_clicker');

  static Future<Point> getCurrentPosition() async {
    try {
      final result = await _channel.invokeMethod('getCurrentPosition');
      return Point(result['x'] as double, result['y'] as double);
    } on PlatformException catch (e) {
      final context = navigatorKey.currentContext;
      final l10n = AppLocalizations.of(context!);
      final errorMessage = l10n.get("failed_get_mouse_position");
      final detailMessage = l10n.getErrorMessage(e.message ?? "unknown_error");
      throw ClickException('$errorMessage: $detailMessage');
    }
  }

  static Future<void> click({int count = 1}) async {
    try {
      await _channel.invokeMethod('click', {'count': count});
    } on PlatformException catch (e) {
      final context = navigatorKey.currentContext;
      final l10n = AppLocalizations.of(context!);
      final errorMessage = l10n.get("failed_click");
      final detailMessage = l10n.getErrorMessage(e.message ?? "unknown_error");
      throw ClickException('$errorMessage: $detailMessage');
    }
  }

  static Future<void> clickAt(Point position) async {
    try {
      await _channel.invokeMethod('clickAt', {
        'x': position.x,
        'y': position.y,
      });
    } on PlatformException catch (e) {
      final context = navigatorKey.currentContext;
      final l10n = AppLocalizations.of(context!);
      final errorMessage = l10n.get("failed_click");
      final detailMessage = l10n.getErrorMessage(e.message ?? "unknown_error");
      throw ClickException('$errorMessage: $detailMessage');
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
