import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:atelier_manager/widgets/main_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Usuário';

    return Scaffold(
        drawer: const MainDrawer(),
        appBar: AppBar(),
        body: Consumer(
          builder: (context, ProductProvider productProvider, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Produtos: ${productProvider.products.length}'),
                  Text('Ordens de produtos: ${productProvider.products.fold(
                      0, (value, product) => value + product.order)}'),
                  Text('Produtos em arquivos: ${productProvider.products.fold(
                      0, (value, product) => value + product.numOnFiles)}'),
                  Text('Produtos impressos: ${productProvider.products.fold(
                      0, (value, product) => value + product.numPrinteds)}'),
                  Text('Produtos prontos: ${productProvider.products.fold(
                      0, (value, product) => value + product.numFinisheds)}'),
                  Text('Produtos vendidos: ${productProvider.products.fold(
                      0, (value, product) => value + product.numSales)}'),
                  // Text('Ganhos totais: R\$ ${productProvider.products
                  //     .fold(
                  //     0.0, (value, product) => value + product.earnings)
                  //     .toStringAsFixed(2)
                  //     .replaceAll('.', ',')}'),
                  // Text('Ganhos este mês: R\$ ${productProvider.products
                  //     .fold(
                  //     0.0, (value, product) => value + product.earningsThisMonth)
                  //     .toStringAsFixed(2)
                  //     .replaceAll('.', ',')}'),
                  // Text('Ganhos este ano: R\$ ${productProvider.products
                  //     .fold(
                  //     0.0, (value, product) => value + product.earningsThisYear)
                  //     .toStringAsFixed(2)
                  //     .replaceAll('.', ',')}'),
                ],
              ),
            );
          }
        ),
    );
  }
}