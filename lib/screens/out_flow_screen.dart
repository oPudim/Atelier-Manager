import 'package:atelier_manager/providers/product_provider.dart';
import 'package:atelier_manager/screens/out_flow_dialog.dart';
import 'package:atelier_manager/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atelier_manager/models/out_flow_data.dart';
import 'package:intl/intl.dart';

class OutFlowScreen extends StatefulWidget {
  const OutFlowScreen({Key? key}) : super(key: key);

  @override
  State<OutFlowScreen> createState() => _OutFlowScreenState();
}

class _OutFlowScreenState extends State<OutFlowScreen> {
  bool show = true;
  String? selectedType; // Add a variable to hold the selected type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saídas'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {show = !show;});
            },
            icon: Icon(
                show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 36,
                color: Colors.black38,
            ),
          ),
          IconButton(
              onPressed: () {
                _showFilterDialog(); // Call the filter dialog function
              },
              icon: Icon(
                  selectedType != null ? Icons.filter_alt_sharp : Icons.filter_alt_outlined,
                  size: 36,
                  color: Colors.black38)
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OutFlowDialog(),
                  fullscreenDialog: true,
                ),
              );
            },
            icon: const Icon(Icons.add_circle, size: 36, color: Colors.black54),
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: MainDrawer(),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          List<OutFlow> outFlows = productProvider.outFlows
            ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Sort by date descending

          // Apply filter if a type is selected
          if (selectedType != null) {
            outFlows = outFlows.where((outFlow) => outFlow.type == selectedType).toList();
          }


          return ListView.separated(
            itemCount: outFlows.length,
            separatorBuilder: (context, index) => const Divider(height: 0.0),
            itemBuilder: (context, index) {
              OutFlow outFlow = outFlows[index];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OutFlowDialog(editOutFlow: outFlow),
                      fullscreenDialog: true,
                    ),
                  );
                },
                child: OutFlowCard(productProvider, outFlow),
              );
            }
          );
        }
      )
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              leading: Radio<String?>(
                value: null,
                groupValue: selectedType,
                onChanged: (String? value) {
                  setState(() {
                    selectedType = value;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('Evento'),
              leading: Radio<String>(
                value: 'event',
                groupValue: selectedType,
                onChanged: (String? value) {
                  setState(() {
                    selectedType = value;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
            // Add other filter options here based on your OutFlow types
            // For example:
            ListTile(
              title: const Text('Encomenda'),
              leading: Radio<String>(
                value: 'order',
                groupValue: selectedType,
                onChanged: (String? value) {setState(() {selectedType = value;});Navigator.of(context).pop();},
              ),
            ),
          ],
        );
      },
    );
  }

  Widget OutFlowCard (ProductProvider productProvider, OutFlow _outFlow) {
    return Container(
      margin: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 10.0,
        bottom: 0.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Text(_outFlow.type == 'event'
                  ? productProvider.findByEventId((_outFlow as EventOutFlow).eventId).name
                  : _outFlow.type == 'order'
                  ? (_outFlow as OrderOutFlow).customerId
                  : _outFlow.type == 'marketplace'
                  ? 'Marketplace'
                  : _outFlow.type == 'loss'
                  ? (_outFlow as LossOutFlow).reason
                  : _outFlow.type == 'gift'
                  ? (_outFlow as GiftOutFlow).recipientId
                  : _outFlow.type == 'barter'
                  ? (_outFlow as BarterOutFlow).partner
                  : '',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                  )
              ),
              const Spacer(),
              Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _outFlow.type == 'event'
                      ? Colors.green
                      : _outFlow.type == 'order'
                      ? Colors.blue
                      : _outFlow.type == 'marketplace'
                      ? Colors.orange
                      : _outFlow.type == 'loss'
                      ? Colors.red
                      : _outFlow.type == 'gift'
                      ? Colors.pink
                      : _outFlow.type == 'barter'
                      ? Colors.purple
                      : Colors.grey,
                ),
                child: Center(
                  child: Text(
                      _outFlow.type == 'event'
                          ? 'Evento'
                          : _outFlow.type == 'order'
                          ? 'Encomenda'
                          : _outFlow.type == 'marketplace'
                          ? 'Marketplace'
                          : _outFlow.type == 'loss'
                          ? 'Perda'
                          : _outFlow.type == 'gift'
                          ? 'Brinde'
                          : _outFlow.type == 'barter'
                          ? 'Escambo'
                          : '',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70
                      )
                  ),
                ),
              ),
            ]
          ),
          Row(
            children: [
              Text("${_outFlow.products.values.fold<int>(0, (sum, amount) => sum + amount)} itens",
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                  )
              ),
              const SizedBox(width: 8),
              Text(
                  "(${_outFlow.products.length} variações)",
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black54
                  )
              ),
              const SizedBox(width: 8),
              if (_outFlow.isSale && !show) Text(
                  "R\$ ${_outFlow.totalValue.toStringAsFixed(2).replaceAll('.', ',')}",
                  style: const TextStyle(
                      fontSize: 10,
                    color: Colors.black54
                  )
              ),
              Spacer(),
              Text(
                  DateFormat('dd/MM/yyyy').format(_outFlow.dateTime),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black38
                  )
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 0.0, color: Colors.black12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 120,
            ),
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              physics: _outFlow.products.length > 14 ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemCount: _outFlow.products.length,
              itemBuilder: (context, index) {
                final product = _outFlow.products.keys.elementAt(index);
                try {
                  final productData = productProvider.findByCode(product);

                  return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Image.network(
                            productData.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return const ColoredBox(
                                color: Colors.grey,
                                child: Center(child: Icon(Icons.error)),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 2,
                            left: 2,
                            child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.black26,
                                child: Text(_outFlow.products[product].toString(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9
                                    ))),
                          )
                        ],
                      )
                  );
                } catch (e) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        const ColoredBox(
                          color: Colors.grey,
                          child: Center(child: Icon(Icons.error)),
                        ),
                        Positioned(
                          bottom: 2,
                          left: 2,
                          child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.black26,
                              child: Text(_outFlow.products[product].toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9
                                  ))),
                        )
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}