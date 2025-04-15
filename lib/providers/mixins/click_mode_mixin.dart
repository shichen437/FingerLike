import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

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

mixin ClickModeMixin on ChangeNotifier {
  ClickMode _clickMode = ClickMode.bionic;
  ClickMode get clickMode => _clickMode;

  void setClickMode(ClickMode mode) {
    _clickMode = mode;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('clickMode', mode.index);
    });
    notifyListeners();
  }
}
