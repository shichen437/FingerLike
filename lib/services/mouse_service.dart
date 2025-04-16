import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

class MouseService {
  static const _channel = MethodChannel('mouse_clicker');
  static AppLocalizations? _l10n;

  static void initialize(AppLocalizations l10n) {
    _l10n = l10n;
  }

  static Future<Point> getCurrentPosition() async {
    try {
      final result = await _channel.invokeMethod('getCurrentPosition');
      return Point(result['x'] as double, result['y'] as double);
    } on PlatformException catch (e) {
      final errorMessage =
          _l10n?.get("failed_get_mouse_position") ??
          "Failed to get mouse position";
      final detailMessage =
          _l10n?.getErrorMessage(e.message ?? "unknown_error") ??
          e.message ??
          "Unknown error";
      throw ClickException('$errorMessage: $detailMessage');
    }
  }

  static Future<void> click({int count = 1}) async {
    try {
      await _channel.invokeMethod('click', {'count': count});
    } on PlatformException catch (e) {
      final errorMessage =
          _l10n?.get("failed_click") ?? "Failed to perform click";
      final detailMessage =
          _l10n?.getErrorMessage(e.message ?? "unknown_error") ??
          e.message ??
          "Unknown error";
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
      final errorMessage =
          _l10n?.get("failed_click") ?? "Failed to perform click";
      final detailMessage =
          _l10n?.getErrorMessage(e.message ?? "unknown_error") ??
          e.message ??
          "Unknown error";
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
