import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task_record.dart';

mixin RecordsStateMixin on ChangeNotifier {
  List<TaskRecord> _taskRecords = [];
  List<TaskRecord> get taskRecords => List.unmodifiable(_taskRecords);

  Future<void> loadTaskRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString('taskRecords');
    if (recordsJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(recordsJson);
        _taskRecords =
            decodedList
                .map(
                  (item) => TaskRecord.fromJson(item as Map<String, dynamic>),
                )
                .toList();
      } catch (e) {
        _taskRecords = [];
      }
    }
    notifyListeners();
  }

  Future<void> _saveTaskRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String recordsJson = jsonEncode(
      _taskRecords.map((record) => record.toJson()).toList(),
    );
    await prefs.setString('taskRecords', recordsJson);
  }

  void addTaskRecord(
    int targetClicks,
    int actualClicks,
    bool completed, {
    String? errorMessage,
    Duration? duration,
    required String mode,
    required int maxRecords,
  }) {
    final newRecord = TaskRecord(
      timestamp: DateTime.now(),
      mode: mode,
      targetClicks: targetClicks,
      actualClicks: actualClicks,
      completed: completed,
      errorMessage: errorMessage,
      duration: duration,
    );
    _taskRecords.insert(0, newRecord);
    _applyMaxRecordsLimit(maxRecords);
    _saveTaskRecords();
    notifyListeners();
  }

  void _applyMaxRecordsLimit(int maxRecords) {
    while (_taskRecords.length > maxRecords) {
      _taskRecords.removeLast();
    }
  }

  void clearAllRecords() {
    _taskRecords.clear();
    _saveTaskRecords();
    notifyListeners();
  }
}
