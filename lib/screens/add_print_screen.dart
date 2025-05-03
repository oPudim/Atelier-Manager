import 'package:atelier_manager/providers/product_provider.dart';
import 'package:atelier_manager/providers/print_provider.dart';
import 'package:atelier_manager/screens/select_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_data.dart';
import '../models/print_data.dart';

class AddPrintScreen extends StatefulWidget {
  const AddPrintScreen({Key? key}) : super(key: key);

  @override
  _AddPrintScreenState createState() => _AddPrintScreenState();
}

class _AddPrintScreenState extends State<AddPrintScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fileController = TextEditingController();
  final TextEditingController _printerController = TextEditingController();
  List<PrintProduct> _products = [];

  @override
  void dispose() {
    _fileController.dispose();
    _printerController.dispose();
    super.dispose();
  }

  void _addProducts(List<Product> products) {
    setState(() {
      for (Product product in products) {
        if(!_products.any((element) => element.code == product.code)){
          _products.add(PrintProduct(code: product.code, amount: 1, failures: -1));
        }
      }
    });
  }

  void _removeProduct(String code) {
    setState(() {
      _products.removeWhere((product) => product.code == code);
    });
  }

  void _updateProductAmount(String code, String value) {
    setState(() {
      int amount = int.tryParse(value) ?? 0;
      if (_products.any((element) => element.code == code)) {
        _products.firstWhere((element) => element.code == code).amount = amount;
      }
    });
  }

  void _savePrint() {
    if (_formKey.currentState!.validate()) {
      if (_products.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adicione pelo menos um produto')),
        );
        return;
      }
      final newPrint = Print(
        dateTime: DateTime.now(),
        file: _fileController.text,
        printer: _printerController.text,
        products: _products,
      );
      Provider.of<PrintProvider>(context, listen: false).savePrint(newPrint);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Impressão'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _fileController,
                decoration: const InputDecoration(labelText: 'Arquivo'),
                validator: (value) => value == null || value.isEmpty ? 'Insira o nome do arquivo' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _printerController,
                decoration: const InputDecoration(labelText: 'Impressora'),
                validator: (value) => value == null || value.isEmpty ? 'Insira o nome da impressora' : null,
              ),
              const SizedBox(height: 20),
              const Text('Produtos:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final List<Product>? selectedProducts = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectProductsScreen(),
                    ),
                  );
                  if (selectedProducts != null) {
                    _addProducts(selectedProducts);
                  }
                },
                child: const Text("Adicionar Produtos"),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ListTile(
                      title: Text('Código: ${product.code}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue: product.amount.toString(),
                            decoration: const InputDecoration(labelText: 'Quantidade'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => _updateProductAmount(product.code, value),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeProduct(product.code),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePrint,
                child: const Text('Salvar Impressão'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}