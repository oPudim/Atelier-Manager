import 'package:atelier_manager/providers/product_provider.dart';
import 'package:atelier_manager/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atelier_manager/models/out_flow_data.dart';

class OutFlowScreen extends StatelessWidget {
  const OutFlowScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saídas'),
        actions: [
          IconButton(
            onPressed: () {

            },
            icon: const Icon(Icons.add_circle, size: 36, color: Colors.black54),
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: MainDrawer(),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          List<OutFlow> outFlows = productProvider.outFlows;

          return ListView.separated(
            itemCount: outFlows.length,
            separatorBuilder: (context, index) => const Divider(height: 0.0),
            itemBuilder: (context, index) {
              OutFlow outFlow = outFlows[index];

              return InkWell(
                onTap: () {

                },
                child: OutFlowCard(),
              );
            }
          );
        }
      )
    );
  }

  Widget OutFlowCard () {
    return Container();
  }
}