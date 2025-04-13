class TaskRecord {
  final DateTime timestamp;
  final String mode;
  final int targetClicks;
  final int actualClicks;
  final bool completed;
  final String? errorMessage;
  final Duration? duration;

  TaskRecord({
    required this.timestamp,
    required this.mode,
    required this.targetClicks,
    required this.actualClicks,
    required this.completed,
    this.errorMessage,
    this.duration,
  });

  String get status {
    if (!completed) {
      return '取消';  // 取消状态直接显示"取消"
    }
    return '完成';
  }
}