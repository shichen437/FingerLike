import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../constants/clicker_enums.dart';

class AppSettings {
  final Color primaryColor;
  final ThemeMode themeMode;
  final ClickMode clickMode;
  final int maxRecords;
  final Locale locale;

  AppSettings({
    required this.primaryColor,
    required this.themeMode,
    required this.clickMode,
    required this.maxRecords,
    required this.locale,
  });
}

class SettingsService {
  static const _kPrefPrimaryColor = 'primaryColor';
  static const _kPrefThemeMode = 'themeMode';
  static const _kPrefClickMode = 'clickMode';
  static const _kPrefMaxRecords = 'maxRecords';
  static const _kPrefLocale = 'locale';

  Future<AppSettings> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final primaryColor = Color(
      prefs.getInt(_kPrefPrimaryColor) ??
          AppColors.defaultThemeColor.toARGB32(),
    );
    final themeMode =
        ThemeMode.values[prefs.getInt(_kPrefThemeMode) ??
            ThemeMode.system.index];
    final clickMode =
        ClickMode.values[prefs.getInt(_kPrefClickMode) ??
            ClickMode.normal.index];
    final maxRecords = prefs.getInt(_kPrefMaxRecords) ?? 20;
    final savedLocale = prefs.getString(_kPrefLocale);
    final locale =
        savedLocale != null ? Locale(savedLocale) : const Locale('zh');

    return AppSettings(
      primaryColor: primaryColor,
      themeMode: themeMode,
      clickMode: clickMode,
      maxRecords: maxRecords,
      locale: locale,
    );
  }

  Future<void> savePrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPrefPrimaryColor, color.toARGB32());
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPrefThemeMode, mode.index);
  }

  Future<void> saveClickMode(ClickMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPrefClickMode, mode.index);
  }

  Future<void> saveMaxRecords(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPrefMaxRecords, value);
  }

  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefLocale, locale.languageCode);
  }
}
