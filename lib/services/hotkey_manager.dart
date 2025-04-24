import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

typedef HotKeyCallback = void Function();

abstract class HotKeyManager {
  Future<void> initialize(HotKeyCallback onHotKeyPressed);
  Future<void> dispose();

  factory HotKeyManager() {
    if (Platform.isAndroid || Platform.isIOS) {
      return _MobileHotKeyManager();
    } else {
      return _DesktopHotKeyManager();
    }
  }
}

class _DesktopHotKeyManager implements HotKeyManager {
  HotKeyCallback? _onHotKeyPressed;
  final HotKey _cancelHotKey = HotKey(
    key: PhysicalKeyboardKey.keyJ,
    modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
    scope: HotKeyScope.system,
  );

  @override
  Future<void> initialize(HotKeyCallback onHotKeyPressed) async {
    _onHotKeyPressed = onHotKeyPressed;
    await hotKeyManager.unregisterAll();
    await hotKeyManager.register(
      _cancelHotKey,
      keyDownHandler: (hotKey) {
        _onHotKeyPressed?.call();
      },
    );
  }

  @override
  Future<void> dispose() async {
    await hotKeyManager.unregister(_cancelHotKey);
  }
}

class _MobileHotKeyManager implements HotKeyManager {

  @override
  Future<void> initialize(HotKeyCallback onHotKeyPressed) async {
    
  }

  @override
  Future<void> dispose() async {
    
  }
}
