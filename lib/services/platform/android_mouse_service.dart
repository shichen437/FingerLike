import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../mouse_service.dart';

class AndroidMouseService implements MousePlatformInterface {
  final MethodChannel _channel;
  final AppLocalizations? _l10n;

  AndroidMouseService(this._channel, this._l10n);

  @override
  Future<Point> getCurrentPosition() async {
    try {
      final result = await _channel.invokeMethod('getCurrentPosition');
      return Point(result['x'], result['y']);
    } on PlatformException catch (e) {
      throw ClickException(_l10n?.get("mousePositionError") ?? e.message ?? '获取位置失败');
    }
  }

  // 添加坐标选择方法
  Future<Map<String, dynamic>> selectCoordinates() async {
    try {
      final result = await _channel.invokeMethod('selectCoordinates');
      if (result['confirmed'] == true) {
        return {
          'confirmed': true,
          'position': Point(result['x'], result['y'])
        };
      } else {
        return {'confirmed': false};
      }
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
          _l10n?.get("failed_click") ??
          "Failed to get mouse position";
      final detailMessage =
          _l10n?.getErrorMessage(e.message ?? "unknown_error") ??
          e.message ??
          "Unknown error";
      throw ClickException('$errorMessage: $detailMessage');
    }
  }
}