import 'package:atelier_manager/models/product_data.dart';
import 'package:atelier_manager/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectProductsScreen extends StatefulWidget {
  const SelectProductsScreen({Key? key}) : super(key: key);

  @override
  _SelectProductsScreenState createState() => _SelectProductsScreenState();
}

class _SelectProductsScreenState extends State<SelectProductsScreen> {
  final List<Product> _selectedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Produtos'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context, _selectedProducts);
            },
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
              return CheckboxListTile(
                title: Text(product.name),
                value: _selectedProducts.contains(product),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedProducts.add(product);
                    } else {
                      _selectedProducts.remove(product);
                    }
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}