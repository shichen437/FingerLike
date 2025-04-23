import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clicker_state.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import 'dart:io' show Platform;
import '../constants/clicker_enums.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsState = Provider.of<SettingsProvider>(context);
    final clickerState = Provider.of<ClickerState>(context);
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.get('clickMode'),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                _buildModeButtons(context, settingsState, clickerState),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.get('historyLimit'),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: settingsState.maxRecords.toDouble(),
                        min: 10,
                        max: 100,
                        divisions: 9,
                        label: settingsState.maxRecords.toString(),
                        onChanged: (value) {
                          settingsState.setMaxRecords(value.toInt());
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('${settingsState.maxRecords}${l10n.get('records')}'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 界面设置卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 添加标题
                Text(
                  l10n.get('interfaceSettings'),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                // 主题颜色设置
                if (Platform.isAndroid || Platform.isIOS) ...[
                  _buildThemeColorAndroid(context, settingsState),
                ] else ...[
                  _buildThemeColorDesktop(context, settingsState),
                ],
                const SizedBox(height: 16),
                // 外观模式设置
                ListTile(
                  title: Row(
                    children: [
                      Text(l10n.get('appearance')),
                      Spacer(),
                      ToggleButtons(
                        constraints: BoxConstraints(minHeight: 36.0),
                        isSelected: [
                          settingsState.themeMode == ThemeMode.system,
                          settingsState.themeMode == ThemeMode.light,
                          settingsState.themeMode == ThemeMode.dark,
                        ],
                        onPressed: (int index) {
                          ThemeMode selectedMode;
                          switch (index) {
                            case 0:
                              selectedMode = ThemeMode.system;
                              break;
                            case 1:
                              selectedMode = ThemeMode.light;
                              break;
                            case 2:
                              selectedMode = ThemeMode.dark;
                              break;
                            default:
                              return;
                          }
                          settingsState.setThemeMode(selectedMode);
                        },
                        children: [
                          if (Platform.isAndroid || Platform.isIOS) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Icon(Icons.settings_brightness),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Icon(Icons.light_mode),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Icon(Icons.dark_mode),
                            ),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Text(l10n.get('followSystem')),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Text(l10n.get('lightMode')),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Text(l10n.get('darkMode')),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 语言设置
                _buildLanguageSetting(context, settingsState),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildThemeColorDesktop(
    BuildContext context,
    SettingsProvider settingsState,
  ) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      title: Text(
        l10n.get('themeColor'),
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children:
              settingsState.availableColors.map((color) {
                final isSelected = settingsState.primaryColor == color;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () => settingsState.setPrimaryColor(color),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: color.withAlpha((0.3 * 255).round()),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                                : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildThemeColorAndroid(
    BuildContext context,
    SettingsProvider settingsState,
  ) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      title: Row(
        children: [
          Text(l10n.get('themeColor')),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    settingsState.availableColors.map((color) {
                      final isSelected = settingsState.primaryColor == color;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => settingsState.setPrimaryColor(color),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  isSelected
                                      ? Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      )
                                      : null,
                              boxShadow:
                                  isSelected
                                      ? [
                                        BoxShadow(
                                          color: color.withAlpha(
                                            (0.3 * 255).round(),
                                          ),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                      : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSetting(
    BuildContext context,
    SettingsProvider settingsState,
  ) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.get('language')),
      trailing: ToggleButtons(
        constraints: BoxConstraints(minHeight: 36.0, minWidth: 60.0),
        isSelected: [
          settingsState.locale.languageCode == 'zh',
          settingsState.locale.languageCode == 'en',
        ],
        onPressed: (int index) {
          final newLocale = index == 0 ? Locale('zh') : Locale('en');
          settingsState.changeLocale(newLocale);
        },
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            child: Text('中文'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            child: Text('English'),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButtons(
    BuildContext context,
    SettingsProvider settingsState,
    ClickerState clickerState,
  ) {
    return Column(
      children:
          ClickMode.values.map((mode) {
            return ListTile(
              title: Text(mode.getDisplayName(context)),
              leading: Radio<ClickMode>(
                value: mode,
                groupValue: settingsState.clickMode,
                onChanged:
                    clickerState.isRunning
                        ? null
                        : (value) {
                          if (value != null) {
                            settingsState.setClickMode(value);
                          }
                        },
              ),
            );
          }).toList(),
    );
  }
}
