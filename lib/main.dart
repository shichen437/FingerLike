import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/clicker_state.dart';
import 'widgets/main_tab_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/app_localizations_delegate.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final clickerState = ClickerState();
  await clickerState.loadPreferences();

  runApp(
    ChangeNotifierProvider.value(
      value: clickerState,
      child: const FingerLike(),  // 添加 const
    ),
  );
}

class FingerLike extends StatelessWidget {
  const FingerLike({super.key});  // 添加 const 构造函数

  @override
  Widget build(BuildContext context) {
    return Consumer<ClickerState>(  // 直接使用 Consumer
      builder: (context, state, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'FingerLike',
          debugShowCheckedModeBanner: false,
          themeMode: state.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.light(
              primary: state.primaryColor,
              secondary: state.primaryColor.withAlpha((0.8 * 255).round()),
            ),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.dark(
              primary: state.primaryColor,
              secondary: state.primaryColor.withAlpha((0.8 * 255).round()),
            ),
            brightness: Brightness.dark,
          ),
          home: const MainTabScreen(),
          locale: state.locale,
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
