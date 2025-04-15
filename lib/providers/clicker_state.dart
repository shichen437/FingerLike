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
import '../main.dart';
import '../constants/clicker_constants.dart';

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

    addTaskRecord(
      targetClicks,
      currentProgress,
      false,
      duration:
          _taskStartTime != null
              ? DateTime.now().difference(_taskStartTime!)
              : null,
      mode: clickMode.name,
    );

    _resetState();
  }

  void _resetState() {
    _currentTask = null;
    _countdownTimer = null;
    _taskStartTime = null;
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

  void _handleClickException(ClickException e, int totalClicks) {
    _countdownTimer?.cancel();
    addTaskRecord(
      totalClicks,
      _progress,
      false,
      errorMessage: e.message,
      duration: DateTime.now().difference(_taskStartTime!),
      mode: clickMode.name,
    );
    _error = e.message;
    _isRunning = false;
    notifyListeners();
  }
  
  Future<bool> _runCountdown() async {
    _remainingSeconds = ClickerConstants.countdownDuration;
    final countdownStartTime = DateTime.now();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      Duration(milliseconds: ClickerConstants.countdownUpdateInterval),
      (timer) {
        if (!_isRunning || _remainingSeconds <= 0) {
          timer.cancel();
          return;
        }
        final now = DateTime.now();
        _remainingSeconds = max(
          0.0,
          ClickerConstants.countdownDuration -
              now.difference(countdownStartTime).inMilliseconds / 1000,
        );
        notifyListeners();
      },
    );

    while (_remainingSeconds > 0 && _isRunning) {
      try {
        _clickPosition = await MouseService.getCurrentPosition();
        await Future.delayed(Duration(milliseconds: ClickerConstants.positionUpdateInterval));
      } on ClickException catch (e) {
        _handleClickException(e, 0);
        return false;
      }
    }
    return _isRunning;
  }

  // 执行点击任务的核心逻辑
  Future<void> _executeClickTask(int totalClicks, Point basePosition) async {
    final random = Random();
    
    for (var i = 0; i < totalClicks; i++) {
      try {
        if (clickMode == ClickMode.bionic) {
          final xOffset = random.nextInt(ClickerConstants.clickPositionVariation * 2 + 1) - 
              ClickerConstants.clickPositionVariation;
          final yOffset = random.nextInt(ClickerConstants.clickPositionVariation * 2 + 1) - 
              ClickerConstants.clickPositionVariation;

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

        final baseDelay = ClickerConstants.baseClickDelay + 
            (i ~/ ClickerConstants.clicksPerSpeedIncrease) * ClickerConstants.speedIncreaseStep;
        final actualDelay = min(ClickerConstants.maxClickDelay, baseDelay);
        final variation = random.nextInt(ClickerConstants.delayVariation * 2 + 1) - 
            ClickerConstants.delayVariation;
        
        await Future.delayed(Duration(milliseconds: actualDelay + variation));
      } on ClickException catch (e) {
        _error = e.message;
        notifyListeners();
        break;
      }
    }
  }

  Future<void> startTask(int totalClicks) async {
    _controller.text = totalClicks.toString();
    _isRunning = true;
    _error = null;
    _taskStartTime = DateTime.now();
    _progress = 0;
    notifyListeners();

    try {
      final countdownSuccess = await _runCountdown();
      if (!countdownSuccess) return;

      // 获取最终点击位置
      try {
        _clickPosition = await MouseService.getCurrentPosition();
      } on ClickException catch (e) {
        _handleClickException(e, totalClicks);
        return;
      }

      _progress = 0;
      final startTime = DateTime.now();
      
      _currentTask = CancelableOperation.fromFuture(
        Future(() => _executeClickTask(totalClicks, _clickPosition!)),
      );

      try {
        await _currentTask?.value;
        addTaskRecord(
          totalClicks,
          _progress,
          _error == null,
          errorMessage: _error,
          duration: DateTime.now().difference(startTime),
          mode: clickMode.name,
        );
      } catch (e) {
        addTaskRecord(
          totalClicks,
          _progress,
          false,
          errorMessage: e.toString(),
          duration: DateTime.now().difference(startTime),
          mode: clickMode.name,
        );
        rethrow;
      }
    } on ClickException catch (e) {
      _handleClickException(e, totalClicks);
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
  Locale _locale = const Locale('zh');

  Locale get locale => _locale;

  void changeLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }
}
