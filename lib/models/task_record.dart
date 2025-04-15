import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

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
      if (errorMessage != null) {
        final message =
            errorMessage!.contains(':')
                ? errorMessage!.split(':').last.trim()
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
      return theme.primaryColor.withOpacity(0.7);
    }
    return theme.primaryColor;
  }

  Color getStatusBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    if (!completed) {
      return theme.primaryColor.withOpacity(0.1);
    }
    return theme.primaryColor.withOpacity(0.15);
  }
}
