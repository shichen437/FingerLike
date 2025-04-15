import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<void> load() async {
    String jsonString = await rootBundle.loadString(
      'lib/l10n/trans/${locale.languageCode}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  String get(String key) {
    return _localizedStrings[key] ?? key;
  }

  String getErrorMessage(String message) {
    if (message == "unknown_error") {
      return get('unknown_error');
    }
    if (message.contains('无效参数')) {
      return get('INVALID_ARG');
    }
    if (message.contains('需要辅助功能权限')) {
      return get('NO_PERMISSION');
    }
    if (message.contains('无法获取屏幕')) {
      return get('NO_SCREEN');
    }
    return message;
  }

  // 添加 supportedLocales 属性
  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('zh', ''),
  ];
}
