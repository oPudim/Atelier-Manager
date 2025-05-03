import 'package:atelier_manager/providers/print_provider.dart';
import 'package:atelier_manager/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/print_data.dart';

class EditPrintScreen extends StatefulWidget {
  final Print print;

  const EditPrintScreen({Key? key, required this.print}) : super(key: key);

  @override
  _EditPrintScreenState createState() => _EditPrintScreenState();
}

class _EditPrintScreenState extends State<EditPrintScreen> {
  late List<PrintProduct> _products;

  @override
  void initState() {
    super.initState();
    _products = [
      ...widget.print.products
    ]; // Creates a copy to avoid direct changes
  }

  void _showFailuresInputDialog(PrintProduct product) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Falhas para ${product.code}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Número de falhas'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _updateProductFailures(product.code, controller.text);
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _updateProductFailures(String code, String value) {
    setState(() {
      int failures = int.tryParse(value) ?? 0;
      if (_products.any((element) => element.code == code)) {
        _products.firstWhere((element) => element.code == code).failures =
            failures;
      }
    });
  }

  void _savePrint() {
    final updatedPrint = Print(
      id: widget.print.id,
      dateTime: widget.print.dateTime,
      file: widget.print.file,
      printer: widget.print.printer,
      products: _products,
    );
    Provider.of<PrintProvider>(context, listen: false).savePrint(updatedPrint);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Impressão'),
      ),
      drawer: const MainDrawer(), // Add the Drawer here
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Arquivo: ${widget.print.file}'),
            Text('Impressora: ${widget.print.printer}'),
            const SizedBox(height: 20),
            const Text('Produtos:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ListTile(
                    title: Text('Código: ${product.code}'),
                    subtitle: Text('Falhas: ${product.failures}'),
                    trailing: ElevatedButton(
                      onPressed: () => _showFailuresInputDialog(product),
                      child: const Text('Editar Falhas'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePrint,
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}