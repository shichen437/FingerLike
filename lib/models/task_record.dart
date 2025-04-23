import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../constants/clicker_enums.dart';

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

  String getStatus(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!completed) {
      if (errorMessage != null &&
          errorMessage!.isNotEmpty &&
          errorMessage != "null") {
        final message =
            errorMessage!.contains(':')
                ? l10n.getErrorMessage(errorMessage!.split(':').last.trim())
                : errorMessage!;
        return '${l10n.get("failed")}($message)';
      }
      return l10n.get('cancelled');
    }
    return l10n.get('completed');
  }

  Color getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    if (!completed) {
      return theme.primaryColor.withAlpha((255 * 0.7).round());
    }
    return theme.primaryColor;
  }

  Color getStatusBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    if (!completed) {
      return theme.primaryColor.withAlpha((255 * 0.1).round());
    }
    return theme.primaryColor.withAlpha((255 * 0.15).round());
  }

  String getMode(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (mode) {
      case 'bionic':
        return l10n.get('bionicMode');
      case 'normal':
        return l10n.get('normalMode');
      default:
        return mode;
    }
  }

  String getDisplayMode(BuildContext context) {
    // 根据存储的标识符获取对应的 ClickMode
    final clickMode = ClickMode.values.firstWhere(
      (m) => m.name == mode,
      orElse: () => ClickMode.normal,
    );
    // 返回本地化的显示名称
    return clickMode.getDisplayName(context);
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.millisecondsSinceEpoch,
    'mode': mode,
    'targetClicks': targetClicks,
    'actualClicks': actualClicks,
    'completed': completed,
    'errorMessage': errorMessage,
    'duration': duration?.inMilliseconds,
  };

  factory TaskRecord.fromJson(Map<String, dynamic> json) => TaskRecord(
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    mode: json['mode'] as String,
    targetClicks: json['targetClicks'] as int,
    actualClicks: json['actualClicks'] as int,
    completed: json['completed'] as bool,
    errorMessage: json['errorMessage'] as String?,
    duration:
        json['duration'] != null
            ? Duration(milliseconds: json['duration'] as int)
            : null,
  );
}
