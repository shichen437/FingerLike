import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clicker_state.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../services/mouse_service.dart';

class ClickControlPanel extends StatefulWidget {
  const ClickControlPanel({super.key});

  @override
  State<ClickControlPanel> createState() => _ClickControlPanelState();
}

class _ClickControlPanelState extends State<ClickControlPanel> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context);
      MouseService.initialize(l10n);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<ClickerState>(
      builder: (context, state, child) {
        return KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.keyC &&
                HardwareKeyboard.instance.isControlPressed &&
                state.isRunning) {
              state.cancelTask();
            }
          },
          child: SingleChildScrollView(
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
                              l10n.get('clickSettings'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                _buildCountInput(l10n),
                                _buildControlButton(state, l10n),
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
                              _buildCountdownDisplay(state, l10n),
                              const SizedBox(height: 24),
                              _buildProgressDisplay(state, l10n),
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
      },
    );
  }

  Widget _buildQuickSelectButtons() {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;
        
        return Center(
          child: isDesktop 
              ? Wrap(
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
                      child: Text(
                        '$count ${l10n.get("times")}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [500, 1000, 3000].map((count) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            minimumSize: const Size(80, 36),
                          ),
                          onPressed: () => _controller.text = count.toString(),
                          child: Text(
                            '$count ${l10n.get("times")}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCountdownDisplay(ClickerState state, AppLocalizations l10n) {
    return Column(
      children: [
        if (state.clickPosition != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              '${l10n.get('clickPosition')}: (${state.clickPosition!.x.toStringAsFixed(0)}, ${state.clickPosition!.y.toStringAsFixed(0)})',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        Row(
          children: [
            Text(
              '${l10n.get('countdownText')}: ${state.remainingSeconds.toStringAsFixed(1)}${l10n.get('seconds')}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                onEnd: () {
                  setState(() {});
                },
                builder: (context, pulseValue, child) {
                  final theme = Theme.of(context);
                  return Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withAlpha(
                            (0.3 * pulseValue * 255).round(),
                          ),
                          blurRadius: 8 * pulseValue,
                          spreadRadius: 2 * pulseValue,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: LinearProgressIndicator(
                      value: (state.remainingSeconds / 7).clamp(0.0, 1.0),
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.primaryColor.withAlpha(
                          (pulseValue * 255).round(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressDisplay(ClickerState state, AppLocalizations l10n) {
    final percentage =
        (state.progress / (int.tryParse(_controller.text) ?? 1)) * 100;
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.primaryColor.withAlpha((0.3 * 255).round()),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 20,
              backgroundColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${l10n.get('clicked')}: ${state.progress} ${l10n.get('times')}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${l10n.get('completed')}: ${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton(ClickerState state, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
        onPressed: () {
          if (state.isRunning) {
            state.cancelTask();
          } else if (_formKey.currentState!.validate()) {
            final count = int.parse(_controller.text);
            state.startTask(count);
          }
        },
        child: Text(
          state.isRunning ? l10n.get('cancelTask') : l10n.get('startTask'),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildCountInput(AppLocalizations l10n) {
    return Expanded(
      child: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: l10n.get('clickCount'),
          border: const OutlineInputBorder(),
          suffixText: l10n.get('times'),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(fontSize: 16),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return l10n.get('pleaseInputClickCount');
          }
          final num = int.tryParse(value);
          if (num == null || num <= 0) {
            return l10n.get('pleaseInputValidNumber');
          }
          return null;
        },
      ),
    );
  }
}
