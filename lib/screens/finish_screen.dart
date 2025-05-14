import 'package:atelier_manager/models/product_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'package:intl/intl.dart';
import '../widgets/main_drawer.dart';
import 'finish_dialog.dart';

class FinalizationScreen extends StatefulWidget {
  const FinalizationScreen({Key? key}) : super(key: key);

  @override
  _FinalizationScreenState createState() => _FinalizationScreenState();
}

class _FinalizationScreenState extends State<FinalizationScreen> {

  Widget finishCard (ProductProvider productProvider, Finished _finish) {
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
              Text("${_finish.products.values.fold<int>(0, (sum, amount) => sum + amount)} itens",
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                  )
              ),
              const SizedBox(width: 8),
              Text(
                  "(${_finish.products.length} variações)",
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black54
                  )
              ),
              Spacer(),
              Text(
                  DateFormat('dd/MM/yyyy').format(_finish.dateTime),
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
              physics: _finish.products.length > 14 ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemCount: _finish.products.length,
              itemBuilder: (context, index) {
                final product = _finish.products.keys.elementAt(index);
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
                                child: Text(_finish.products[product].toString(),
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
                              child: Text(_finish.products[product].toString(),
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

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final sortFinishes = List<Finished>.from(productProvider.finisheds);
    sortFinishes.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizações'),
        actions: [
          IconButton(
            onPressed: () {
              _showAddFinishDialog(context);
            },
            icon: const Icon(
              Icons.add_circle,
              size: 36,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: const MainDrawer(),
      body: ListView.separated(
        separatorBuilder: (context, index) => const Divider(height: 0.0),
        itemCount: sortFinishes.length,
        itemBuilder: (context, index){
          final finish = sortFinishes[index];
          return InkWell(
            onLongPress:() {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      finishCard(productProvider, finish),
                      Divider(height: 0.0),
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Editar'),
                        onTap: () {
                          Navigator.of(context).pop();
                          _showEditFinishDialog(context, finish);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text('Excluir'),
                        onTap: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Excluir finalização?'),
                                content: const Text('Essa ação não poderá ser desfeita.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      productProvider.deleteFinished(finish);
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Finalização excluída.'),
                                        ),
                                      );
                                    },
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: finishCard(productProvider, finish),
          );
        },
      ),
    );
  }


  void _showAddFinishDialog(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: true,
        fullscreenDialog: true,
        pageBuilder: (context, _, __) => FinishDialog()));
  }

  void _showEditFinishDialog(BuildContext context, Finished finished) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: true,
        fullscreenDialog: true,
        pageBuilder: (context, _, __) => FinishDialog(editFinished: finished)));
  }
}