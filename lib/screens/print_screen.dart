import 'package:atelier_manager/models/product_data.dart';
import 'print_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/main_drawer.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';

class PrintsScreen extends StatefulWidget {
  const PrintsScreen({Key? key}) : super(key: key);

  @override
  State<PrintsScreen> createState() => _PrintsScreenState();
}

class _PrintsScreenState extends State<PrintsScreen> {
  bool _showOnlyNotYetPrinted = true;

  @override
  void initState() {
    super.initState();
  }

  Widget finishCard (ProductProvider productProvider, PrintFile _printFile) {
    return Container(
      margin: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 10.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              _printFile.fileName,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold
              )
          ),
          Text(
              _printFile.printerName,
              style: const TextStyle(
                  fontSize: 10,
                color: Colors.black45
              )
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(_printFile.productOnFile.values.fold<int>(0, (sum, amount) => sum + amount).toString(),
                  style: const TextStyle(fontSize: 12)
              ),
              if (_printFile.isPrinted) Row(
                children: [
                  const Icon(Icons.arrow_right, size: 20),
                  Text(
                      _printFile.productPrinted.values.fold<int>(0, (sum, amount) => sum + amount).toString(),
                      style: const TextStyle(fontSize: 12)
                  )
                ],
              ),
              Text(" itens", style: const TextStyle(fontSize: 12,)),
              const SizedBox(width: 8),
              Text(
                  "(${_printFile.productOnFile.length} variações)",
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black45
                  )
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.create, size: 12, color: Colors.black26),
                      const SizedBox(width: 5),
                      Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(_printFile.fileDateTime),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black38
                          )
                      ),
                    ],
                  ),
                  if (_printFile.isPrinted) Row(
                    children: [
                      Icon(Icons.print, size: 12, color: Colors.black26),
                      const SizedBox(width: 5),
                      Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(_printFile.printDateTime),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black38
                          )
                      ),
                    ],
                  ),
                ],
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
              physics: _printFile.productOnFile.length > 14 ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemCount: _printFile.productOnFile.length,
              itemBuilder: (context, index) {
                final product = _printFile.productOnFile.keys.elementAt(index);
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
                                child: Text(_printFile.productOnFile[product].toString(),
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
                              child: Text(_printFile.productOnFile[product].toString(),
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Impressões'),
          ],
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'ALL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  )
              ),
              Switch(
                trackOutlineColor: WidgetStateProperty
                    .resolveWith<Color?>((_) => Colors.transparent),
                activeColor: Colors.black12,
                activeTrackColor: Colors.black45,
                inactiveThumbColor: Colors.black45,
                inactiveTrackColor: Colors.black12,


                value: !_showOnlyNotYetPrinted,
                onChanged: (bool value) {
                  setState(() {
                    _showOnlyNotYetPrinted = !value;
                  });
                },
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrintDialog(),
                ),
              );
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
      drawer: const MainDrawer(), // Add the Drawer here
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          List<PrintFile> filteredFiles = _showOnlyNotYetPrinted
              ? productProvider.printFiles.where((file) => !file.isPrinted).toList()
              : productProvider.printFiles;

          // Order by date time desc
          filteredFiles.sort((a,b) => b.fileDateTime.compareTo(a.fileDateTime));

          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(height: 0.0),
            itemCount: filteredFiles.length,
            itemBuilder: (context, index) => finishCard(productProvider, filteredFiles[index]),
          );
        },
      ),
    );
  }

  Widget _buildProductList(PrintFile file) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemCount: file.productOnFile.length,
          itemBuilder: (context, index) {
            final product = file.productOnFile.entries.elementAt(index);
            try {
              final productData = productProvider.findByCode(file.productOnFile.keys.elementAt(index));

              return ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Quina boleada
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
                            child: Text(file.productOnFile.values.elementAt(index).toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10
                                ))),
                      )
                    ],
                  )
              );
            } catch (e) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10), // Quina boleada
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
                          child: Text(file.productOnFile.values.elementAt(index).toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10
                              ))),
                    )
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

}