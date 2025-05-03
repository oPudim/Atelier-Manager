import 'package:atelier_manager/widgets/main_drawer.dart';
import 'package:flutter/material.dart';

class AddPrintScreen extends StatefulWidget {
  const AddPrintScreen({super.key});

  @override
  State<AddPrintScreen> createState() => _AddPrintScreenState();
}

class _AddPrintScreenState extends State<AddPrintScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Impressão'),
      ),
      drawer: const MainDrawer(), // Add the Drawer here
      body: const Center(
        child: Text('Adicionar Impressão'),
      ),
    );
  }
}