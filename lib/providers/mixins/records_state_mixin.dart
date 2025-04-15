import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task_record.dart';
import 'click_mode_mixin.dart';

mixin RecordsStateMixin on ChangeNotifier {
  final List<TaskRecord> _taskRecords = [];
  List<TaskRecord> get taskRecords => List.unmodifiable(_taskRecords);

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

  void clearAllRecords() {
    _taskRecords.clear();
    notifyListeners();
  }

  void addTaskRecord(
    int targetClicks,
    int actualClicks,
    bool completed, {
    String? errorMessage,
    Duration? duration,
    required String mode,
  }) {
    _taskRecords.add(
      TaskRecord(
        timestamp: DateTime.now(),
        mode: mode,
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
}
