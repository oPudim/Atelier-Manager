import 'package:flutter/material.dart';

class FinalizationScreen extends StatelessWidget {
  const FinalizationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalização'),
      ),
      body: const Center(
        child: Text('Tela de Finalização'),
      ),
    );
  }
}