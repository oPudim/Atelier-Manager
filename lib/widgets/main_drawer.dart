import 'package:flutter/material.dart';
import 'package:atelier_manager/providers/product_provider.dart';
import 'package:atelier_manager/models/product_data.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.error),
            title: const Text('Perdas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/losses');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Ferramentas'),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              _showFullScreenToolsDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showFullScreenToolsDialog(BuildContext context) {
    showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const FullScreenToolsDialog();
        });
  }
}

class FullScreenToolsDialog extends StatefulWidget {
  const FullScreenToolsDialog({Key? key}) : super(key: key);

  @override
  State<FullScreenToolsDialog> createState() => _FullScreenToolsDialogState();
}

class _FullScreenToolsDialogState extends State<FullScreenToolsDialog> {
  String fileName = "";
  String filePath = "";
  final _confirmationController = TextEditingController();
  bool _isLoading = false;
  double _progress = 0;
  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog(int itemCount, String fileName, Function function) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        fileName = fileName.split('.').first;
        return AlertDialog(
          title: const Text('Confirmar Adição'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                  text: TextSpan(
                    text: 'Você está prestes a adicionar ',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text: '$itemCount',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold
                          )
                      ),
                      const TextSpan(text: ' itens.')
                    ],
                  )
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: 'Escreva ',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: fileName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    const TextSpan(text: ' para confirmar')
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _confirmationController,
                decoration: InputDecoration(
                  hintText: fileName,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmationController.clear();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_confirmationController.text == fileName) {
                  setState(() {
                    _isLoading = true;
                    _progress = 0;
                  });
                  Navigator.of(context).pop();
                  function(filePath);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Confirmação incorreta!'),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addProducts(String filePath) async {
    try {
      List<Product> products = await Provider.of<ProductProvider>(context, listen: false).getProducts(filePath);
      await Provider.of<ProductProvider>(context, listen: false).addProducts(products, onProgress: (progress) {
        setState(() {
          _progress = progress;
        });
      });
      setState(() {
        _isLoading = false;
        _progress = 0;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produtos adicionados com sucesso!'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar produtos: $e'),
          ),
        );
      }
    }
  }

  Future<void> _addPrintFiles(String filePath) async {
    try {
      List<PrintFile> printFile = await Provider.of<ProductProvider>(context, listen: false).getPrints(filePath);
      await Provider.of<ProductProvider>(context, listen: false).addPrints(printFile, onProgress: (progress) {
        setState(() {
          _progress = progress;
        });
      });
      setState(() {
        _isLoading = false;
        _progress = 0;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impressões adicionadas com sucesso!'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar impressões: $e'),
          ),
        );
      }
    }
  }

  Future<void> _addFinisheds(String filePath) async {
    try {
      List<Finished> finished = await Provider.of<ProductProvider>(context, listen: false).getFinisheds(filePath);
      await Provider.of<ProductProvider>(context, listen: false).addFinisheds(finished, onProgress: (progress) {
        setState(() {
          _progress = progress;
        });
      });
      setState(() {
        _isLoading = false;
        _progress = 0;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Finalizações adicionadas com sucesso!'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar finalizações: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ferramentas'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              Text('Adicionando Produtos (${(_progress * 100).toStringAsFixed(0)}%)...'),
              const SizedBox(height: 16),
              CircularProgressIndicator(
                value: _progress,
              ),
            ] else ...[
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                      );
                      if (result != null) {
                        filePath = result.files.single.path!;
                        fileName = result.files.single.name;
                        List<Product> products = await Provider.of<ProductProvider>(context, listen: false).getProducts(filePath);
                        if (products.isNotEmpty) {
                          _showConfirmationDialog(products.length, fileName, _addProducts);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Arquivo Vazio!'),
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nenhum arquivo selecionado.'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Adicionar Produtos em Massa'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                      );
                      if (result != null) {
                        filePath = result.files.single.path!;
                        fileName = result.files.single.name;
                        List<PrintFile> printFiles = await Provider.of<ProductProvider>(context, listen: false).getPrints(filePath);
                        if (printFiles.isNotEmpty) {
                          _showConfirmationDialog(printFiles.length, fileName, _addPrintFiles);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Arquivo Vazio!'),
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nenhum arquivo selecionado.'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Adicionar impressões em Massa'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                      );
                      if (result != null) {
                        filePath = result.files.single.path!;
                        fileName = result.files.single.name;
                        List<Finished> finisheds = await Provider.of<ProductProvider>(context, listen: false).getFinisheds(filePath);
                        if (finisheds.isNotEmpty) {
                          _showConfirmationDialog(finisheds.length, fileName, _addFinisheds);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Arquivo Vazio!'),
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nenhum arquivo selecionado.'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Adicionar finalizações em Massa'),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}