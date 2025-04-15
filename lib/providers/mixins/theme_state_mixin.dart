import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';

mixin ThemeStateMixin on ChangeNotifier {
  Color _primaryColor = AppColors.defaultThemeColor;
  Color get primaryColor => _primaryColor;
  List<Color> get availableColors => AppColors.themeColors;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('primaryColor', color.value);
    });
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('themeMode', mode.index);
    });
    notifyListeners();
  }

  Locale _locale = const Locale('zh');
  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('locale', newLocale.languageCode);
      });
      notifyListeners();
    }
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = Locale(prefs.getString('locale') ?? 'zh');

    // 加载语言设置
    final savedLocale = prefs.getString('locale');
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    }
  }
}
