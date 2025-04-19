import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clicker_state.dart';
import '../providers/mixins/click_mode_mixin.dart';
import '../l10n/app_localizations.dart';
import 'dart:io' show Platform;

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ClickerState>(context);
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
                _buildModeButtons(context, state),
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
                        value: state.maxRecords.toDouble(),
                        min: 10,
                        max: 100,
                        divisions: 9,
                        label: state.maxRecords.toString(),
                        onChanged: (value) {
                          state.setMaxRecords(value.toInt());
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('${state.maxRecords}${l10n.get('records')}'),
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
                  _buildThemeColorAndroid(context, state),
                ] else ...[
                  _buildThemeColorDesktop(context, state),
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
                          state.themeMode == ThemeMode.system,
                          state.themeMode == ThemeMode.light,
                          state.themeMode == ThemeMode.dark,
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
                          state.setThemeMode(selectedMode);
                        },
                        children: [
                          if (Platform.isAndroid || Platform.isIOS) ...[
                            const Icon(Icons.settings_brightness),
                            const Icon(Icons.light_mode),
                            const Icon(Icons.dark_mode),
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
                _buildLanguageSetting(context),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildThemeColorDesktop(BuildContext context, ClickerState state) {
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
              state.availableColors.map((color) {
                final isSelected = state.primaryColor == color;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () => state.setPrimaryColor(color),
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
    );
  }

  Widget _buildThemeColorAndroid(BuildContext context, ClickerState state) {
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
                    state.availableColors.map((color) {
                      final isSelected = state.primaryColor == color;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => state.setPrimaryColor(color),
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

  Widget _buildLanguageSetting(BuildContext context) {
    final state = Provider.of<ClickerState>(context);
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.get('language')),
      trailing: ToggleButtons(
        constraints: BoxConstraints(minHeight: 36.0, minWidth: 60.0),
        isSelected: [
          state.locale.languageCode == 'zh',
          state.locale.languageCode == 'en',
        ],
        onPressed: (int index) {
          final newLocale = index == 0 ? Locale('zh') : Locale('en');
          state.changeLocale(newLocale);
        },
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ), // 调整垂直边距
            child: Text('中文'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ), // 调整垂直边距
            child: Text('English'),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButtons(BuildContext context, ClickerState state) {
    return Column(
      children:
          ClickMode.values.map((mode) {
            return ListTile(
              title: Text(mode.getDisplayName(context)),
              leading: Radio<ClickMode>(
                value: mode,
                groupValue: state.clickMode,
                onChanged:
                    state.isRunning
                        ? null
                        : (value) {
                          if (value != null) {
                            state.setClickMode(value);
                          }
                        },
              ),
            );
          }).toList(),
    );
  }
}
