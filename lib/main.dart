import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/clicker_state.dart';
import 'widgets/click_control_panel.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => ClickerState(),
    child: const ClickerApp(),
  ),
);

class ClickerApp extends StatelessWidget {
  const ClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FingerLike',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ClickerScreen(),
    );
  }
}

class ClickerScreen extends StatelessWidget {
  const ClickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FingerLike')),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: ClickControlPanel(),
      ),
    );
  }
}
