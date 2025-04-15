import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'dart:io' show Platform;
import 'providers/clicker_state.dart';
import 'widgets/click_control_panel.dart';
import 'widgets/records_panel.dart';
import 'widgets/settings_panel.dart';
import 'widgets/about_panel.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/app_localizations_delegate.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FingerLike());
}

class FingerLike extends StatelessWidget {
  final ClickerState state = ClickerState();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => state,
      child: Consumer<ClickerState>(
        builder: (context, state, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'FingerLike',
            themeMode: state.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.light(
                primary: state.primaryColor,
                secondary: state.primaryColor.withOpacity(0.8),
              ),
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.dark(
                primary: state.primaryColor,
                secondary: state.primaryColor.withOpacity(0.8),
              ),
              brightness: Brightness.dark,
            ),
            routes: {'/settings': (context) => const SettingsPanel()},
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
      ),
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

void navigateToSettings(BuildContext context) {
  Navigator.pushNamed(context, '/settings');
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ClickControlPanel(),
    RecordsPanel(),
    SettingsPanel(),
    AboutPanel(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 88,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: ShaderMask(
            shaderCallback: (bounds) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final baseColor =
                  isDark ? Colors.white : Theme.of(context).primaryColor;
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor,
                  baseColor.withOpacity(0.8),
                  baseColor.withOpacity(0.6),
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            child: Text(
              'FingerLike',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTab(0, l10n.get('home')),
                _buildTab(1, l10n.get('history')),
                _buildTab(2, l10n.get('settings')),
                _buildTab(3, l10n.get('about')),
              ],
            ),
          ),
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    String tabTitle;
    switch (index) {
      case 0:
        tabTitle = l10n.get('home');
        break;
      case 1:
        tabTitle = l10n.get('history');
        break;
      case 2:
        tabTitle = l10n.get('settings');
        break;
      case 3:
        tabTitle = l10n.get('about');
        break;
      default:
        tabTitle = '';
    }

    IconData icon;
    switch (index) {
      case 0:
        icon = Icons.mouse;
        break;
      case 1:
        icon = Icons.history;
        break;
      case 2:
        icon = Icons.settings;
        break;
      case 3:
        icon = Icons.info_outline;
        break;
      default:
        icon = Icons.circle;
    }

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? theme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? (isDark ? Colors.white : theme.primaryColor)
                      : (isDark ? Colors.grey[400] : Colors.grey),
            ),
            const SizedBox(width: 8),
            Text(
              tabTitle,
              style: TextStyle(
                color:
                    isSelected
                        ? (isDark ? Colors.white : theme.primaryColor)
                        : (isDark ? Colors.grey[400] : Colors.grey),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
