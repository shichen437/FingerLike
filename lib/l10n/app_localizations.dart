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
    if (message.contains('请开启无障碍服务')) {
      return get('ACCESSIBILITY_SERVICE');
    }
    return message;
  }

  String getFormattedEstimatedTime(double estimatedTime) {
    if (estimatedTime < 60) {
      return estimatedTime.toStringAsFixed(1) + get("seconds");
    } else if (estimatedTime < 3600) {
      final minutes = (estimatedTime / 60).floor();
      final remainingSeconds = estimatedTime % 60;
      return minutes.toString() +
          get("minutes") +
          remainingSeconds.toStringAsFixed(0) +
          get("seconds");
    } else {
      final hours = (estimatedTime / 3600).floor();
      final minutes = ((estimatedTime % 3600) / 60).floor();
      return hours.toString() +
          get("hours") +
          minutes.toString() +
          get("minutes");
    }
  }

  // 添加 supportedLocales 属性
  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('zh', ''),
  ];
}
