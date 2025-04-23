import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum TaskStatus { idle, countingDown, running, completed, cancelled, error }

enum ClickMode { bionic, normal }

extension ClickModeExtension on ClickMode {
  String getDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case ClickMode.bionic:
        return l10n.get('bionicMode');
      case ClickMode.normal:
        return l10n.get('normalMode');
    }
  }
}
