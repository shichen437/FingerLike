import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../mouse_service.dart';

class MacOSMouseService implements MousePlatformInterface {
  final MethodChannel _channel;
  final AppLocalizations? _l10n;

  MacOSMouseService(this._channel, this._l10n);

  @override
  Future<Point> getCurrentPosition() async {
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

  @override
  Future<void> clickAt(Point position) async {
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
