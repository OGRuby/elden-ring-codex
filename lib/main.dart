import 'package:flutter/material.dart';

void main() {
  runApp(const EldenRingCodexApp());
}

class EldenRingCodexApp extends StatelessWidget {
  const EldenRingCodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elden Ring Codex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC9A876),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Elden Ring Codex - w budowie'),
        ),
      ),
    );
  }
}