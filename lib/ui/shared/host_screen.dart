import 'package:flutter/material.dart';

class HostScreen extends StatelessWidget {
  const HostScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная')),
      body: const Center(child: Text('Стартовый экран')),
    );
  }
}