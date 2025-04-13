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
      if (errorMessage != null) {
        final message = errorMessage!.contains(':') 
            ? errorMessage!.split(':').last.trim()
            : errorMessage!;
        return '失败($message)';
      }
      return '取消';
    }
    return '完成';
  }
}