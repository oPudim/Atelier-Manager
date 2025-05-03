import 'package:flutter/material.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendas'),
      ),
      body: const Center(
        child: Text('Tela de Vendas'),
      ),
    );
  }
}