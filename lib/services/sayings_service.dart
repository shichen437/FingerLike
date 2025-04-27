import 'package:sayings/sayings.dart';

class SayingsService {
  Future<String> getWeeklySayingsContent(String lang) async {
    Language languageCode = Language.en;
    if (lang == 'zh') {
      languageCode = Language.zh;
    }
    try {
      var sayings = Sayings();
      return await sayings.getRandomSayingContent(
        type: SayingType.week,
        language: languageCode,
      );
    } catch (e) {
      return 'Enjoy everyday!';
    }
  }
}
