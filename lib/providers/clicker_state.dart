import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'settings_provider.dart';
import 'mixins/records_state_mixin.dart';
import '../constants/clicker_constants.dart';
import '../services/mouse_service.dart';
import '../constants/clicker_enums.dart';

class ClickerState with ChangeNotifier, RecordsStateMixin {
  final TextEditingController _controller = TextEditingController();
  Timer? _countdownTimer;
  CancelableOperation? _currentTask;
  DateTime? _taskStartTime;

  double _remainingSeconds = 7.0;
  int _progress = 0;
  TaskStatus _taskStatus = TaskStatus.idle;
  Point? _clickPosition;
  String? _error;

  final SettingsProvider _settingsProvider;

  ClickerState(this._settingsProvider) {
    _settingsProvider.addListener(_handleSettingsChange);
  }

  void _handleSettingsChange() {
    notifyListeners();
  }

  bool get isRunning =>
      _taskStatus == TaskStatus.countingDown ||
      _taskStatus == TaskStatus.running;
  TaskStatus get taskStatus => _taskStatus;

  double get remainingSeconds => _remainingSeconds;
  int get progress => _progress;
  Point? get clickPosition => _clickPosition;
  String? get error => _error;

  void cancelTask() {
    if (!isRunning) return;

    final currentProgress = _progress;
    final targetClicks =
        _controller.text.isNotEmpty ? int.tryParse(_controller.text) ?? 0 : 0;

    _currentTask?.cancel();
    _countdownTimer?.cancel();

    _taskStatus = TaskStatus.cancelled;

    addTaskRecord(
      targetClicks,
      currentProgress,
      false,
      duration:
          _taskStartTime != null
              ? DateTime.now().difference(_taskStartTime!)
              : null,
      mode: _settingsProvider.clickMode.name,
      maxRecords: _settingsProvider.maxRecords,
    );

    _resetState();
  }

  void _resetState() {
    _currentTask = null;
    _countdownTimer = null;
    _taskStartTime = null;
    _remainingSeconds = ClickerConstants.countdownDuration;
    _progress = 0;
    _taskStatus = TaskStatus.idle;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    _settingsProvider.removeListener(_handleSettingsChange);
    super.dispose();
  }

  void _handleClickException(ClickException e, int totalClicks) {
    _countdownTimer?.cancel();
    _taskStatus = TaskStatus.error;
    _error = e.message;

    addTaskRecord(
      totalClicks,
      _progress,
      false,
      errorMessage: _error,
      duration:
          _taskStartTime != null
              ? DateTime.now().difference(_taskStartTime!)
              : null,
      mode: _settingsProvider.clickMode.name,
      maxRecords: _settingsProvider.maxRecords,
    );

    notifyListeners();
  }

  Future<bool> _runCountdown() async {
    _remainingSeconds = ClickerConstants.countdownDuration;
    final countdownStartTime = DateTime.now();
    _taskStatus = TaskStatus.countingDown;
    notifyListeners();
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      Duration(milliseconds: ClickerConstants.countdownUpdateInterval),
      (timer) {
        if (_taskStatus != TaskStatus.countingDown || _remainingSeconds <= 0) {
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

    if (Platform.isAndroid || Platform.isIOS) {
      while (_remainingSeconds > 0 && isRunning) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _taskStatus == TaskStatus.countingDown;
    }

    while (_remainingSeconds > 0 && isRunning) {
      try {
        _clickPosition = await MouseService.getCurrentPosition();
        await Future.delayed(
          Duration(milliseconds: ClickerConstants.positionUpdateInterval),
        );
      } on ClickException catch (e) {
        _handleClickException(e, 0);
        return false;
      }
    }
    return _taskStatus == TaskStatus.countingDown;
  }

  Future<void> _executeClickTask(int totalClicks, Point basePosition) async {
    final random = Random();
    _taskStatus = TaskStatus.running;
    notifyListeners();
    for (var i = 0; i < totalClicks; i++) {
      if (_taskStatus != TaskStatus.running) break;
      try {
        if (_settingsProvider.clickMode == ClickMode.bionic) {
          final xOffset =
              random.nextInt(ClickerConstants.clickPositionVariation * 2 + 1) -
              ClickerConstants.clickPositionVariation;
          final yOffset =
              random.nextInt(ClickerConstants.clickPositionVariation * 2 + 1) -
              ClickerConstants.clickPositionVariation;

          final clickPosition = Point(
            basePosition.x + xOffset,
            basePosition.y + yOffset,
          );

          await MouseService.clickAt(clickPosition);
        } else {
          await MouseService.clickAt(basePosition);
        }

        _progress = i + 1;
        notifyListeners();

        final baseDelay =
            ClickerConstants.baseClickDelay +
            (i ~/ ClickerConstants.clicksPerSpeedIncrease) *
                ClickerConstants.speedIncreaseStep;
        final actualDelay = min(ClickerConstants.maxClickDelay, baseDelay);
        final variation =
            random.nextInt(ClickerConstants.delayVariation * 2 + 1) -
            ClickerConstants.delayVariation;

        await Future.delayed(Duration(milliseconds: actualDelay + variation));
      } on ClickException catch (e) {
        _handleClickException(e, totalClicks);
        return;
      }
    }
    if (_taskStatus == TaskStatus.running) {
      _taskStatus = TaskStatus.completed;
      addTaskRecord(
        totalClicks,
        _progress,
        true,
        duration: DateTime.now().difference(_taskStartTime!),
        mode: _settingsProvider.clickMode.name,
        maxRecords: _settingsProvider.maxRecords,
      );
      _resetState();
    }
  }

  Future<void> startTask(int totalClicks) async {
    if (isRunning) return;
    _controller.text = totalClicks.toString();
    _taskStatus = TaskStatus.idle;
    _error = null;
    _taskStartTime = DateTime.now();
    _progress = 0;
    notifyListeners();

    Point? finalClickPosition;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final result = await MouseService.selectCoordinates();
        if (result['confirmed'] != true) {
          _resetState();
          return;
        }
        finalClickPosition = result['position'];
        _clickPosition = finalClickPosition;
        notifyListeners();
      }

      final countdownSuccessful = await _runCountdown();
      if (!countdownSuccessful) {
        if (_taskStatus != TaskStatus.error) {
          _resetState();
        }
        return;
      }

      // 获取最终点击位置 (桌面平台)
      if (!Platform.isAndroid && !Platform.isIOS) {
        try {
          finalClickPosition = await MouseService.getCurrentPosition();
          _clickPosition = finalClickPosition;
          notifyListeners();
        } on ClickException catch (e) {
          _handleClickException(e, totalClicks);
          return;
        }
      }

      if (finalClickPosition == null) {
        _taskStatus = TaskStatus.error;
        _error = "未能确定点击位置";
        addTaskRecord(
          totalClicks,
          0,
          false,
          errorMessage: _error,
          mode: _settingsProvider.clickMode.name,
          maxRecords: _settingsProvider.maxRecords,
        );
        notifyListeners();
        return;
      }

      _progress = 0;
      notifyListeners();

      _currentTask = CancelableOperation.fromFuture(
        _executeClickTask(totalClicks, finalClickPosition),
        onCancel: () {},
      );

      await _currentTask?.valueOrCancellation();
    } on ClickException catch (e) {
      if (_taskStatus != TaskStatus.error &&
          _taskStatus != TaskStatus.cancelled) {
        _handleClickException(e, totalClicks);
      }
    } catch (e) {
      if (_taskStatus != TaskStatus.error &&
          _taskStatus != TaskStatus.cancelled) {
        _taskStatus = TaskStatus.error;
        _error = "发生未知错误: ${e.toString()}";
        addTaskRecord(
          totalClicks,
          _progress,
          false,
          errorMessage: _error,
          duration:
              _taskStartTime != null
                  ? DateTime.now().difference(_taskStartTime!)
                  : null,
          mode: _settingsProvider.clickMode.name,
          maxRecords: _settingsProvider.maxRecords,
        );
        notifyListeners();
      }
    } finally {
      _countdownTimer?.cancel();
      _currentTask = null;

      if (_taskStatus != TaskStatus.completed &&
          _taskStatus != TaskStatus.cancelled &&
          _taskStatus != TaskStatus.error) {
        _resetState();
      }
    }
  }

  double calculateEstimatedTime(int totalClicks) {
    if (totalClicks <= 0) return 0;

    double totalMilliseconds = 0;
    int speedIncreaseStages =
        (totalClicks - 1) ~/ ClickerConstants.clicksPerSpeedIncrease;
    double clickOperationTime = _getPlatformClickTime();

    // 计算每个阶段的点击数
    int remainingClicks = totalClicks;
    int baseClicks = min(
      remainingClicks,
      ClickerConstants.clicksPerSpeedIncrease,
    );
    remainingClicks -= baseClicks;

    totalMilliseconds +=
        baseClicks * (ClickerConstants.baseClickDelay + clickOperationTime);

    if (remainingClicks > 0) {
      double avgSpeedIncrease =
          (speedIncreaseStages * ClickerConstants.speedIncreaseStep) / 2;
      double avgDelay = min(
        ClickerConstants.maxClickDelay.toDouble(),
        ClickerConstants.baseClickDelay + avgSpeedIncrease,
      );

      totalMilliseconds += remainingClicks * avgDelay;
    }

    return totalMilliseconds / 1000;
  }

  double _getPlatformClickTime() {
    if (Platform.isAndroid) {
      return 100.0;
    } else if (Platform.isMacOS || Platform.isWindows) {
      return 50.0;
    } else {
      return 50.0;
    }
  }
}
