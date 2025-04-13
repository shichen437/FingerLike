import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clicker_state.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ClickerState>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('点击模式', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 24),
                    _buildModeButtons(state),
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
                    Text('记录设置', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          '最大记录数量: ${state.maxRecords}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 16),
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 添加回模式选择按钮构建方法
  Widget _buildModeButtons(ClickerState state) {
    return Column(
      children:
          ClickMode.values.map((mode) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(mode.displayName),
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
              ),
            );
          }).toList(),
    );
  }
}
