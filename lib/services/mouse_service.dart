import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'dart:io';
import 'platform/macos_mouse_service.dart';
import 'platform/windows_mouse_service.dart';

abstract class MousePlatformInterface {
  Future<Point> getCurrentPosition();
  Future<void> clickAt(Point position);
}

class MouseService {
  static late final MousePlatformInterface _platformImpl;
  static AppLocalizations? _l10n;
  static bool _isInitialized = false;

  static void initialize(AppLocalizations l10n) {
    if (_isInitialized) return;
    _isInitialized = true;
    _l10n = l10n;
    _platformImpl = _createPlatformImpl();
  }

  static MousePlatformInterface _createPlatformImpl() {
    if (Platform.isMacOS) {
      return MacOSMouseService(_channel, _l10n);
    } else if (Platform.isWindows) {
      return WindowsMouseService(_l10n);
    }
    throw UnsupportedError('当前平台不支持鼠标操作');
  }

  static const _channel = MethodChannel('mouse_clicker');

  static Future<Point> getCurrentPosition() async {
    return _platformImpl.getCurrentPosition();
  }

  static Future<void> clickAt(Point position) async {
    return _platformImpl.clickAt(position);
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
