import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../constants/clicker_enums.dart';
import '../theme/app_colors.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  Color _primaryColor = AppColors.defaultThemeColor;
  ThemeMode _themeMode = ThemeMode.system;
  ClickMode _clickMode = ClickMode.bionic;
  int _maxRecords = 20;
  Locale _locale = const Locale('zh');

  Color get primaryColor => _primaryColor;
  ThemeMode get themeMode => _themeMode;
  ClickMode get clickMode => _clickMode;
  int get maxRecords => _maxRecords;
  Locale get locale => _locale;
  List<Color> get availableColors => AppColors.themeColors;

  Future<void> initializeSettings() async {
    final settings = await _settingsService.loadPreferences();
    _primaryColor = settings.primaryColor;
    _themeMode = settings.themeMode;
    _clickMode = settings.clickMode;
    _maxRecords = settings.maxRecords;
    _locale = settings.locale;
  }

  void setPrimaryColor(Color color, {bool save = true}) {
    if (_primaryColor == color) return;
    _primaryColor = color;
    notifyListeners();
    if (save) {
      _settingsService.savePrimaryColor(color);
    }
  }

  void setThemeMode(ThemeMode mode, {bool save = true}) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    if (save) {
      _settingsService.saveThemeMode(mode);
    }
  }

  void setClickMode(ClickMode mode, {bool save = true}) {
    if (_clickMode == mode) return;
    _clickMode = mode;
    notifyListeners();
    if (save) {
      _settingsService.saveClickMode(mode);
    }
  }

  void setMaxRecords(int value, {bool save = true}) {
    final clampedValue = value.clamp(10, 100);
    if (_maxRecords == clampedValue) return;
    _maxRecords = clampedValue;
    notifyListeners();
    if (save) {
      _settingsService.saveMaxRecords(clampedValue);
    }
  }

  void changeLocale(Locale newLocale, {bool save = true}) {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
    if (save) {
      _settingsService.saveLocale(newLocale);
    }
  }
}
