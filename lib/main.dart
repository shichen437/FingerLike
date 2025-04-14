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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final state = ClickerState();
  await state.loadPreferences();

  if (Platform.isMacOS || Platform.isWindows) {
    await hotKeyManager.unregisterAll();
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      minimumSize: Size(600, 400),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    final hotKey = HotKey(
      key: LogicalKeyboardKey.keyC,
      modifiers: [HotKeyModifier.control],
      scope: HotKeyScope.system,
    );
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        final state = Provider.of<ClickerState>(
          navigatorKey.currentContext!,
          listen: false,
        );
        if (state.isRunning) {
          state.cancelTask();
        }
      },
    );
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => state,
      child: const ClickerApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ClickerApp extends StatelessWidget {
  const ClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClickerState>(
      builder: (context, state, _) {
        return MaterialApp(
          title: 'FingerLike',
          theme: ThemeData(
            colorScheme: ColorScheme.light(
              primary: state.primaryColor,
              secondary: state.primaryColor.withOpacity(0.8),
            ),
          ),
          home: const MainTabScreen(),
        );
      },
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ClickControlPanel(),
    RecordsPanel(),
    SettingsPanel(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FingerLike'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 48,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton(0, Icons.home, '主页'),
                _buildTabButton(1, Icons.history, '记录'),
                _buildTabButton(2, Icons.settings, '设置'),
              ],
            ),
          ),
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }

  Widget _buildTabButton(int index, IconData icon, String label) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor:
            _selectedIndex == index
                ? Theme.of(context).primaryColor
                : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onPressed: () => setState(() => _selectedIndex = index),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
