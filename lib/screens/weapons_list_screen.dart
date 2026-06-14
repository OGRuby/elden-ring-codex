import 'package:flutter/material.dart';

class WeaponsListScreen extends StatelessWidget {
  const WeaponsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Broń')),
      body: const Center(child: Text('Lista broni - w budowie')),
    );
  }
}