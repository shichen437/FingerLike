import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/clicker_state.dart';
import 'providers/settings_provider.dart';
import 'widgets/main_tab_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/app_localizations_delegate.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider();
  await settingsProvider.initializeSettings();

  final clickerState = ClickerState(settingsProvider);
  await clickerState.loadTaskRecords();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: clickerState),
      ],
      child: const FingerLike(),
    ),
  );
}

class FingerLike extends StatelessWidget {
  const FingerLike({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsState, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'FingerLike',
          debugShowCheckedModeBanner: false,
          themeMode: settingsState.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.light(
              primary: settingsState.primaryColor,
              secondary: settingsState.primaryColor.withAlpha(
                (0.8 * 255).round(),
              ),
            ),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.dark(
              primary: settingsState.primaryColor,
              secondary: settingsState.primaryColor.withAlpha(
                (0.8 * 255).round(),
              ),
            ),
            brightness: Brightness.dark,
          ),
          home: const MainTabScreen(),
          locale: settingsState.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
