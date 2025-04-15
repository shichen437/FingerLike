import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import '../services/mouse_service.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../theme/app_colors.dart';
import 'mixins/theme_state_mixin.dart';
import 'mixins/records_state_mixin.dart';
import 'mixins/click_mode_mixin.dart';

class ClickerState
    with ChangeNotifier, ThemeStateMixin, RecordsStateMixin, ClickModeMixin {
  final TextEditingController _controller = TextEditingController();
  Timer? _countdownTimer;
  CancelableOperation? _currentTask;
  DateTime? _taskStartTime;

  double _remainingSeconds = 7.0;
  int _progress = 0;
  bool _isRunning = false;
  Point? _clickPosition;
  String? _error;

  // Getters
  double get remainingSeconds => _remainingSeconds;
  int get progress => _progress;
  bool get isRunning => _isRunning;
  Point? get clickPosition => _clickPosition;
  String? get error => _error;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setPrimaryColor(
      Color(prefs.getInt('primaryColor') ?? AppColors.defaultThemeColor.value),
    );
    setThemeMode(
      ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.system.index],
    );
    setClickMode(ClickMode.values[prefs.getInt('clickMode') ?? 0]);
    setMaxRecords(prefs.getInt('maxRecords') ?? 20);
  }

  void cancelTask() {
    if (!_isRunning) return;
  
    final currentProgress = _progress;
    final targetClicks =
        _controller.text.isNotEmpty ? int.tryParse(_controller.text) ?? 0 : 0;
  
    _currentTask?.cancel();
    _countdownTimer?.cancel();
  
    if (_currentTask != null) {
      _currentTask!.cancel();
      _currentTask = null;
    }
  
    // 将 mode 参数改为枚举值
    addTaskRecord(
      targetClicks,
      currentProgress,
      false,
      duration: _taskStartTime != null 
          ? DateTime.now().difference(_taskStartTime!)
          : null,
      mode: clickMode.toString(), // 转换为字符串
    );
  
    _resetState();
  }
  
  void _resetState() {
    _currentTask = null;
    _countdownTimer = null;
    _taskStartTime = null; // 清除任务开始时间
    _remainingSeconds = 7;
    _progress = 0;
    _isRunning = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> startTask(int totalClicks) async {
    _controller.text = totalClicks.toString();
    _isRunning = true;
    _error = null;
    _taskStartTime = DateTime.now();
    _progress = 0;
    notifyListeners();

    try {
      _remainingSeconds = 7.0;
      final countdownStartTime = DateTime.now();

      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(milliseconds: 16), (
        timer,
      ) {
        if (!_isRunning || _remainingSeconds <= 0) {
          timer.cancel();
          return;
        }

        final now = DateTime.now();
        _remainingSeconds = max(
          0.0,
          7.0 - now.difference(countdownStartTime).inMilliseconds / 1000,
        );
        notifyListeners();
      });

      // 等待倒计时结束
      while (_remainingSeconds > 0 && _isRunning) {
        try {
          _clickPosition = await MouseService.getCurrentPosition();
          await Future.delayed(const Duration(milliseconds: 100));
        } on ClickException catch (e) {
          _countdownTimer?.cancel();
          // 修改所有 addTaskRecord 调用
          addTaskRecord(
            totalClicks,
            _progress,
            false,
            errorMessage: e.message,
            duration: DateTime.now().difference(_taskStartTime!),
            mode: clickMode.toString(), // 直接传递枚举值
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
        await Future.delayed(const Duration(milliseconds: 100));
      } on ClickException catch (e) {
        _countdownTimer?.cancel();
        addTaskRecord(
          totalClicks,
          _progress,
          false,
          errorMessage: e.message,
          duration: DateTime.now().difference(_taskStartTime!),
          mode: clickMode.toString(), // 修改这里：将 ClickMode 转换为字符串
        );
        _error = e.message;
        _isRunning = false;
        notifyListeners();
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
              if (clickMode == ClickMode.bionic) {
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
        addTaskRecord(
          totalClicks,
          _progress,
          _error == null,
          errorMessage: _error,
          duration: DateTime.now().difference(startTime),
          mode: clickMode.toString(), // 转换为字符串
        );
      } catch (e) {
        addTaskRecord(
          totalClicks,
          _progress,
          false,
          errorMessage: e.toString(),
          duration: DateTime.now().difference(startTime),
          mode: clickMode.toString(), // 转换为字符串
        );
        rethrow;
      } finally {
        _isRunning = false;
        notifyListeners();
      }
    } on ClickException catch (e) {
      addTaskRecord(
        totalClicks,
        _progress,
        false,
        errorMessage: e.message,
        duration: DateTime.now().difference(_taskStartTime!),
        mode: clickMode.toString(), // 转换为字符串
      );
      _error = e.message;
      notifyListeners();
      rethrow;
    } finally {
      if (_isRunning) {
        _isRunning = false;
        notifyListeners();
      }
      _countdownTimer?.cancel();
    }
  }

  // 添加locale相关属性和方法
  Locale _locale = const Locale('zh'); // 默认中文
  
  Locale get locale => _locale;
  
  void changeLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }
}
