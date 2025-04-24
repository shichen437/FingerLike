import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/clicker_state.dart';
import 'providers/settings_provider.dart';
import 'widgets/main_tab_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/app_localizations_delegate.dart';
import 'services/hotkey_manager.dart';

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

class FingerLike extends StatefulWidget {
  const FingerLike({super.key});

  @override
  State<FingerLike> createState() => _FingerLikeState();
}

class _FingerLikeState extends State<FingerLike> {
  late final HotKeyManager _hotKeyManager;

  @override
  void initState() {
    super.initState();
    _hotKeyManager = HotKeyManager();
    final clickerState = Provider.of<ClickerState>(context, listen: false);
    _initializeHotKey(clickerState);
  }

  Future<void> _initializeHotKey(ClickerState clickerState) async {
    try {
      await _hotKeyManager.initialize(clickerState.cancelTask);
    } catch (e) {
      // 占位
    }
  }

  @override
  void dispose() {
    _hotKeyManager.dispose();
    super.dispose();
  }

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
