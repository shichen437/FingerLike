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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主题颜色卡片
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('主题颜色', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.availableColors.map((color) {
                          return GestureDetector(
                            onTap: () => state.setPrimaryColor(color),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(20),
                                border: state.primaryColor == color
                                    ? Border.all(color: Colors.white, width: 3)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 模式选择卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('点击模式', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    _buildModeButtons(state),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 历史记录限制卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('历史记录限制', style: TextStyle(fontSize: 18)),
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
                        Text('${state.maxRecords}条'),
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
}

// 添加回模式选择按钮构建方法
Widget _buildModeButtons(ClickerState state) {
  return Column(
    children: ClickMode.values.map((mode) {
      return ListTile(
        title: Text(mode.displayName),
        leading: Radio<ClickMode>(
          value: mode,
          groupValue: state.clickMode,
          onChanged: state.isRunning
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
