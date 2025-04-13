import 'package:flutter/foundation.dart';
import 'package:async/async.dart';
import '../services/mouse_service.dart';
import 'dart:math';

class ClickerState with ChangeNotifier {
  int _remainingSeconds = 7;
  int _progress = 0;
  CancelableOperation? _currentTask;
  bool _isRunning = false;
  Point? _clickPosition;
  Point? get clickPosition => _clickPosition;

  int get remainingSeconds => _remainingSeconds;
  int get progress => _progress;
  bool get isRunning => _isRunning;

  String? _error;
  String? get error => _error;

  bool _isBionicMode = false;
  bool get isBionicMode => _isBionicMode;

  void toggleMode() {
    _isBionicMode = !_isBionicMode;
    notifyListeners();
  }

  // 修改模式相关的属性
  ClickMode _clickMode = ClickMode.bionic;
  ClickMode get clickMode => _clickMode;

  void setClickMode(ClickMode mode) {
    _clickMode = mode;
    notifyListeners();
  }

  Future<void> startTask(int totalClicks) async {
    _isRunning = true;
    _error = null;
    notifyListeners();

    try {
      // 倒计时逻辑，同时实时更新鼠标位置
      _remainingSeconds = 7;
      while (_remainingSeconds > 0) {
        // 实时获取鼠标位置
        _clickPosition = await MouseService.getCurrentPosition();
        notifyListeners();

        await Future.delayed(const Duration(seconds: 1));
        _remainingSeconds--;
        notifyListeners();
      }

      // 最后一次获取鼠标位置，这将是实际任务的起始位置
      _clickPosition = await MouseService.getCurrentPosition();
      notifyListeners();

      // 执行点击任务
      _progress = 0;
      // 修改点击任务部分
      _currentTask = CancelableOperation.fromFuture(
        Future(() async {
          final random = Random();
          final basePosition = _clickPosition!; // 保存基础位置

          for (var i = 0; i < totalClicks; i++) {
            try {
              if (_clickMode == ClickMode.bionic) {
                // 计算浮动位置
                final xOffset = random.nextInt(41) - 20; // -20 到 20 之间
                final yOffset = random.nextInt(41) - 20;

                final clickPosition = Point(
                  basePosition.x + xOffset,
                  basePosition.y + yOffset,
                );

                await MouseService.clickAt(clickPosition);
              } else {
                await MouseService.click(); // 普通模式保持原样
              }

              _progress = i + 1;
              notifyListeners();

              // 计算基础间隔时间
              final baseDelay = 120 + (i ~/ 300) * 30;
              final actualDelay = min(600, baseDelay); // 确保不超过600ms

              // 添加随机浮动
              final variation = random.nextInt(41) - 20; // -20 到 20 之间的随机数
              await Future.delayed(
                Duration(milliseconds: actualDelay + variation),
              );
            } on ClickException catch (e) {
              _error = e.message;
              notifyListeners();
              break;
            }
          }
        }),
      );
      await _currentTask?.value;
    } finally {
      _isRunning = false;
      _clickPosition = null;
      notifyListeners();
    }
  }

  void cancelTask() {
    _currentTask?.cancel();
    _remainingSeconds = 7;
    _progress = 0;
    _isRunning = false;
    _error = null;
    notifyListeners();
  }
}

enum ClickMode { bionic, normal }

extension ClickModeExtension on ClickMode {
  String get displayName {
    switch (this) {
      case ClickMode.bionic:
        return '仿生模式';
      case ClickMode.normal:
        return '普通模式';
    }
  }
}
