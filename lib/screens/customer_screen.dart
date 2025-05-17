import 'package:atelier_manager/screens/customer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atelier_manager/providers/product_provider.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({Key? key}) : super(key: key); // Construtor básico

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const CustomerDialog();
              }));
            },
          )
        ],
      ),

      body: Consumer(
        builder: (context, ProductProvider productProvider, child) {
          return productProvider.customers.isEmpty
              ? Center(child: Text('Nenhum cliente cadastrado.'))
              : ListView.builder(
            itemCount: productProvider.customers.length,
            itemBuilder: (context, costumer) {
              final customer = productProvider.customers[costumer];
              return InkWell(
                onLongPress: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CustomerDialog(editCustomer: customer);
                  }));
                },
                child: ListTile(
                  title: Text(customer.name),
                  subtitle: Text(customer.id),
                ),
              );
            },
          );
        }
      ),
    );
  }
}