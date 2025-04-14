import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import '../services/mouse_service.dart';
import 'dart:math';
import '../models/task_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClickerState with ChangeNotifier {
  final TextEditingController _controller = TextEditingController();
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

  ClickMode _clickMode = ClickMode.bionic;
  ClickMode get clickMode => _clickMode;

  // 保留这个带持久化的setClickMode方法，移除上面的简单版本
  void setClickMode(ClickMode mode) {
    _clickMode = mode;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('clickMode', mode.index);
    });
    notifyListeners();
  }

  final List<TaskRecord> _taskRecords = [];
  List<TaskRecord> get taskRecords => List.unmodifiable(_taskRecords);
  DateTime? _taskStartTime;

  Color _primaryColor = Colors.blueGrey;
  Color get primaryColor => _primaryColor;

  final List<Color> availableColors = [
    Colors.blueGrey,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _primaryColor = Color(prefs.getInt('primaryColor') ?? Colors.blueGrey.value);
    _clickMode = ClickMode.values[prefs.getInt('clickMode') ?? 0];
    _maxRecords = prefs.getInt('maxRecords') ?? 20;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('primaryColor', color.value);
    });
    notifyListeners();
  }

  // 删除这里的第二个setClickMode方法定义
  int _maxRecords = 20;
  int get maxRecords => _maxRecords;

  void setMaxRecords(int value) {
    _maxRecords = value.clamp(10, 100);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('maxRecords', _maxRecords);
    });
    while (_taskRecords.length > _maxRecords) {
      _taskRecords.removeAt(0);
    }
    notifyListeners();
  }

  void _addTaskRecord(
    int targetClicks,
    int actualClicks,
    bool completed, {
    String? errorMessage,
    Duration? duration,
  }) {
    _taskRecords.add(
      TaskRecord(
        timestamp: DateTime.now(),
        mode: _clickMode.displayName,
        targetClicks: targetClicks,
        actualClicks: actualClicks,
        completed: completed,
        errorMessage: errorMessage,
        duration: duration,
      ),
    );

    while (_taskRecords.length > _maxRecords) {
      _taskRecords.removeAt(0);
    }
    notifyListeners();
  }

  void cancelTask() {
    if (!_isRunning) return;

    final currentProgress = _progress;
    final targetClicks =
        _controller.text.isNotEmpty ? int.tryParse(_controller.text) ?? 0 : 0;

    _currentTask?.cancel();

    _addTaskRecord(
      targetClicks,
      currentProgress,
      false,
      duration:
          _taskStartTime != null
              ? DateTime.now().difference(_taskStartTime!)
              : null,
    );

    _remainingSeconds = 7;
    _progress = 0;
    _isRunning = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void clearAllRecords() {
    _taskRecords.clear();
    notifyListeners();
  }

  Future<void> startTask(int totalClicks) async {
    _controller.text = totalClicks.toString();
    _isRunning = true;
    _error = null;
    _taskStartTime = DateTime.now();
    _progress = 0;
    notifyListeners();

    try {
      // 倒计时逻辑，同时实时更新鼠标位置
      _remainingSeconds = 7;
      while (_remainingSeconds > 0 && _isRunning) {
        try {
          // 实时获取鼠标位置
          _clickPosition = await MouseService.getCurrentPosition();
          notifyListeners();

          await Future.delayed(const Duration(seconds: 1));
          if (!_isRunning) break;
          _remainingSeconds--;
          notifyListeners();
        } on ClickException catch (e) {
          _addTaskRecord(
            totalClicks,
            _progress,
            false,
            errorMessage: e.message,
            duration: DateTime.now().difference(_taskStartTime!),
          );
          _error = e.message;
          _isRunning = false;
          notifyListeners();
          return;
        }
      }

      if (!_isRunning) return;

      // 最后一次获取鼠标位置，这将是实际任务的起始位置
      try {
        _clickPosition = await MouseService.getCurrentPosition();
        notifyListeners();
      } on ClickException catch (e) {
        _addTaskRecord(
          totalClicks,
          _progress,
          false,
          errorMessage: e.message,
          duration: DateTime.now().difference(_taskStartTime!),
        );
        _error = e.message;
        notifyListeners();
        _isRunning = false;
        return;
      }

      // 执行点击任务
      _progress = 0;
      final startTime = DateTime.now();
      _currentTask = CancelableOperation.fromFuture(
        Future(() async {
          final random = Random();
          final basePosition = _clickPosition!;

          for (var i = 0; i < totalClicks; i++) {
            try {
              if (_clickMode == ClickMode.bionic) {
                // 计算浮动位置
                final xOffset = random.nextInt(41) - 20;
                final yOffset = random.nextInt(41) - 20;

                final clickPosition = Point(
                  basePosition.x + xOffset,
                  basePosition.y + yOffset,
                );

                await MouseService.clickAt(clickPosition);
              } else {
                await MouseService.click();
              }

              _progress = i + 1;
              notifyListeners();

              // 计算基础间隔时间
              final baseDelay = 120 + (i ~/ 300) * 30;
              final actualDelay = min(600, baseDelay);

              // 添加随机浮动
              final variation = random.nextInt(41) - 20;
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
      try {
        await _currentTask?.value;

        // 任务完成时添加记录
        _addTaskRecord(
          totalClicks,
          _progress,
          _error == null,
          errorMessage: _error,
          duration: DateTime.now().difference(startTime),
        );
      } catch (e) {
        _addTaskRecord(
          totalClicks,
          _progress,
          false,
          errorMessage: e.toString(),
          duration: DateTime.now().difference(startTime),
        );
        rethrow;
      } finally {
        _isRunning = false;
        notifyListeners();
      }
    } on ClickException catch (e) {
      _addTaskRecord(
        totalClicks,
        _progress,
        false,
        errorMessage: e.message,
        duration: DateTime.now().difference(_taskStartTime!),
      );
      _error = e.message;
      notifyListeners();
      rethrow;
    } finally {
      if (_isRunning) {
        _isRunning = false;
        notifyListeners();
      }
    }
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
