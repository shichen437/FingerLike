import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clicker_state.dart';

class ClickControlPanel extends StatefulWidget {
  const ClickControlPanel({super.key});

  @override
  State<ClickControlPanel> createState() => _ClickControlPanelState();
}

class _ClickControlPanelState extends State<ClickControlPanel> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ClickerState>(
      builder: (context, state, child) => SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                        Text(
                          '点击设置',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildCountInput(),
                            _buildControlButton(state),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildQuickSelectButtons(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (state.isRunning) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildCountdownDisplay(state),
                          const SizedBox(height: 24),
                          _buildProgressDisplay(state),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 移除_buildModeSelector方法定义

  Widget _buildQuickSelectButtons() {
    return Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [500, 1000, 3000].map((count) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            onPressed: () => _controller.text = count.toString(),
            child: Text('$count 次', style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCountdownDisplay(ClickerState state) {
    return Column(
      children: [
        if (state.clickPosition != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              '点击位置: (${state.clickPosition!.x.toStringAsFixed(0)}, ${state.clickPosition!.y.toStringAsFixed(0)})',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 7.0, end: 0.0),
          duration: Duration(seconds: state.remainingSeconds),
          builder: (context, value, _) {
            return RepaintBoundary(
              // 添加 RepaintBoundary
              child: Column(
                children: [
                  SizedBox(
                    // 固定大小
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      value: 1 - (value / 7),
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '倒计时: ${state.remainingSeconds}秒',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressDisplay(ClickerState state) {
    final percentage =
        (state.progress / (int.tryParse(_controller.text) ?? 1)) * 100;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 20,
              backgroundColor: Colors.blue.shade50,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '已点击: ${state.progress} 次',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '完成: ${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton(ClickerState state) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120, 48), // 设置按钮最小尺寸
        ),
        onPressed: () {
          if (state.isRunning) {
            state.cancelTask();
          } else if (_formKey.currentState!.validate()) {
            final count = int.parse(_controller.text);
            state.startTask(count);
          }
        },
        child: Text(
          state.isRunning ? '取消任务' : '开始任务',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCountInput() {
    return Expanded(
      // 添加 Expanded 让输入框占据剩余空间
      child: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: '点击次数',
          border: OutlineInputBorder(),
          suffixText: '次',
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(fontSize: 16),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '请输入点击次数';
          }
          final num = int.tryParse(value);
          if (num == null || num <= 0) {
            return '请输入有效正整数值';
          }
          return null;
        },
      ),
    );
  }

  // 删除从这里开始的第二个 build 方法
  // @override
  // Widget build(BuildContext context) { ... }
}
