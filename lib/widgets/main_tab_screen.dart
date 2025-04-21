import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../l10n/app_localizations.dart';
import 'click_control_panel.dart';
import 'records_panel.dart';
import 'settings_panel.dart';
import 'about_panel.dart';

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
    AboutPanel(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar:
          Platform.isAndroid || Platform.isIOS
              ? AppBar(
                toolbarHeight: 64,
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      final baseColor =
                          isDark
                              ? Colors.white
                              : Theme.of(context).primaryColor;
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          baseColor,
                          baseColor.withAlpha((0.8 * 255).round()),
                          baseColor.withAlpha((0.6 * 255).round()),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds);
                    },
                    child: Text(
                      'FingerLike',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                elevation: 0,
              )
              : AppBar(
                toolbarHeight: 88,
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      final baseColor =
                          isDark
                              ? Colors.white
                              : Theme.of(context).primaryColor;
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          baseColor,
                          baseColor.withAlpha((0.8 * 255).round()),
                          baseColor.withAlpha((0.6 * 255).round()),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds);
                    },
                    child: Text(
                      'FingerLike',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
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
                    color: Theme.of(
                      context,
                    ).primaryColor.withAlpha((0.1 * 255).round()),
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
      bottomNavigationBar:
          Platform.isAndroid || Platform.isIOS
              ? Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(
                        context,
                      ).primaryColor.withAlpha((0.1 * 255).round()),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTab(0, l10n.get('home')),
                    _buildTab(1, l10n.get('history')),
                    _buildTab(2, l10n.get('settings')),
                    _buildTab(3, l10n.get('about')),
                  ],
                ),
              )
              : null,
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final showText = !Platform.isAndroid && !Platform.isIOS;

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
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: showText ? 24 : 16,
        ),
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
            if (showText) ...[
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color:
                      isSelected
                          ? (isDark ? Colors.white : theme.primaryColor)
                          : (isDark ? Colors.grey[400] : Colors.grey),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
