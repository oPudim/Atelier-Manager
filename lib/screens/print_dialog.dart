import 'dart:ffi';

import 'package:atelier_manager/models/product_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'package:intl/intl.dart';

class PrintDialog extends StatefulWidget {
  final PrintFile? editPrintFile;

  const PrintDialog({Key? key, this.editPrintFile}) : super(key: key);

  @override
  _PrintDialogState createState() => _PrintDialogState();
}

class _PrintDialogState extends State<PrintDialog> {

  late ProductProvider productProvider;
  Map<String, int> _onFileProducts = {};
  Map<String, int> _printedProducts = {};
  DateTime _selectedFileDate = DateTime.now();
  DateTime? _selectedPrintDate;

  late TextEditingController _fileNameController;
  late TextEditingController _printerNameController;
  String _fileName = '';
  String _printerName = '';
  bool _orderLimit = true;

  bool? isDataChanged = false;

  @override
  void initState() {
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    DateTime _selectedPrintDate = _selectedFileDate;
    if (widget.editPrintFile != null) {
      _onFileProducts = widget.editPrintFile!.productOnFile.map((key, value) => MapEntry(key, value));
      _printedProducts = widget.editPrintFile!.productPrinted.map((key, value) => MapEntry(key, value));
      _selectedFileDate = widget.editPrintFile!.fileDateTime;
      _selectedPrintDate = widget.editPrintFile!.printDateTime;
      _fileName = widget.editPrintFile!.fileName;
      _printerName = widget.editPrintFile!.printerName;
    }
    _fileNameController = TextEditingController(text: _fileName);
    _printerNameController = TextEditingController(text: _printerName);
    super.initState();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _printerNameController.dispose();
    super.dispose();
  }

  void _removeProduct(String productCode) {
    setState(() {
      _onFileProducts.remove(productCode);
    });
  }

  void _finalizePrint() {
    if (_onFileProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um produto para finalizar.'),
        ),
      );
      return;
    }
    Map<String, int> productsOnFileToSave = {};
    Map<String, int> productsPrintedToSave = {};
    _onFileProducts.forEach((productCode, productAmount) {
      productsOnFileToSave[productCode] = productAmount;
    });
    _printedProducts.forEach((productCode, productAmount) {
      productsPrintedToSave[productCode] = productAmount;
    });
    final newPrintFile = PrintFile(
      id: '',
      fileDateTime: _selectedFileDate,
      printDateTime: _selectedPrintDate ?? _selectedFileDate,
      productOnFile: productsOnFileToSave,
      productPrinted: productsPrintedToSave,
      fileName: _fileNameController.text,
      printerName: _printerNameController.text,
    );
    if (widget.editPrintFile == null) {
      productProvider.savePrint(newPrintFile);
      Navigator.of(context).pop();
    } else {
      isDataChanged = false;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirmar alteração do arquivo?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Alterar a data criará um novo arquivo e excluirá o anterior.'),
                if (widget.editPrintFile!.fileDateTime != _selectedFileDate) Row(
                  children: [
                    Checkbox(
                      value: isDataChanged,
                      onChanged: (bool? value) {
                        (context as Element).markNeedsBuild();
                        setState(() {
                          isDataChanged = value;
                        });
                      },
                    ),
                    Text('Alterar data.')
                  ],
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar')),
              TextButton(onPressed: () {
                if (widget.editPrintFile!.fileDateTime != _selectedFileDate) {
                  if (isDataChanged == true) {
                    productProvider.savePrint(newPrintFile);
                    productProvider.deletePrint(widget.editPrintFile!);
                  } else {
                    productProvider.updatePrint(PrintFile(
                        id: widget.editPrintFile!.id,
                        fileDateTime: widget.editPrintFile!.fileDateTime,
                        printDateTime: widget.editPrintFile!.printDateTime,
                        productOnFile: productsOnFileToSave,
                        productPrinted: productsPrintedToSave,
                        fileName: widget.editPrintFile!.fileName,
                        printerName: widget.editPrintFile!.printerName
                    ));}
                } else {
                  productProvider.updatePrint(newPrintFile);
                  }
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }, child: const Text('Confirmar')),
            ],
          );
        },
      );
    }
  }

  Future<void> _selectFileDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      locale: const Locale('pt', 'BR'),
      context: context,
      initialDate: _selectedFileDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      builder: (context, child) {
        return Localizations.override(
            context: context,
            locale: const Locale('pt', 'BR'),
            child: child
        );
        },
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedFileDate),
    );
    if (pickedTime != null && pickedTime != _selectedFileDate) {
      setState(() {
        _selectedFileDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime?.hour ?? _selectedFileDate.hour,
          pickedTime?.minute ?? _selectedFileDate.minute,
        );
      });
    }
  }

  Future<void> _selectPrintDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      locale: const Locale('pt', 'BR'),
      context: context,
      initialDate: _selectedPrintDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      builder: (context, child) {
        return Localizations.override(
            context: context,
            locale: const Locale('pt', 'BR'),
            child: child
        );
      },
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedPrintDate!),
    );
  }

  void _buildSuggestions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: 500,
          child: ProductSearchModal(
            productProvider: productProvider,
            editPrintFile: widget.editPrintFile,
            onFileProducts: _onFileProducts, // Passa os produtos já adicionados
            orderLimit: _orderLimit,
            onProductSelected: (product) { // Callback para lidar com a seleção de produto
              setState(() { // Atualiza o estado do _PrintDialogState
                if (_onFileProducts.containsKey(product.code)) {
                  _onFileProducts[product.code] = _onFileProducts[product.code]! + 1;
                } else {
                  _onFileProducts[product.code] = 1;
                }
                // A navegação de pop() já está dentro do ProductSearchModal
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buildSuggestions(),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('${widget.editPrintFile == null ? 'Novo' : 'Editar'} arquivo'),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Limite de\nordem',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                    color: Colors.black54,
                  )
              ),
              const SizedBox(width: 5.0),
              Switch(
                trackOutlineColor: WidgetStateProperty
                    .resolveWith<Color?>((_) => Colors.transparent),
                activeColor: Colors.black12,
                activeTrackColor: Colors.black45,
                inactiveThumbColor: Colors.black45,
                inactiveTrackColor: Colors.black12,
                value: _orderLimit,
                onChanged: (bool value) {
                  setState(() {
                    _orderLimit = value;
                  });
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _finalizePrint,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: DropdownMenu<String>(
                    dropdownMenuEntries: productProvider.fileNames.map((fileName) {
                      return DropdownMenuEntry(value: fileName, label: fileName);
                    }).toList(),
                    controller: _fileNameController,
                    //expandedInsets: EdgeInsets.zero,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    label: Text('Arquivo'),
                    inputDecorationTheme: const InputDecorationTheme(
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                    ),
                    onSelected: (String? selectedFileName) {
                      if (selectedFileName != null) {
                        setState(() {
                          _fileName = selectedFileName;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 1,
                  child: DropdownMenu<String>(
                    dropdownMenuEntries: productProvider.printerNames.map((printerName) {
                      return DropdownMenuEntry(value: printerName, label: printerName);
                    }).toList(),
                    controller: _printerNameController,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    label: Text('Impressora'),
                    inputDecorationTheme: const InputDecorationTheme(
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                    ),
                    onSelected: (String? selectedPrinterName) {
                      if (selectedPrinterName != null) {
                        setState(() {
                          _printerName = selectedPrinterName;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Divider(),
            const SizedBox(height: 5.0),
            Row(
              children: [
                Text(
                  'Produtos Adicionados:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _selectFileDate(context),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${DateFormat('dd/MM/yyyy').format(_selectedFileDate)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),
                      Icon(Icons.date_range, color: Colors.black, size: 22)
                    ],
                  )
                )
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _onFileProducts.isEmpty
                  ? const Center(child: Text('Nenhum produto adicionado.'))
                  : ListView.builder(
                itemCount: _onFileProducts.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.findByCode(
                        _onFileProducts.keys.elementAt(index));
                    final amount = _onFileProducts.values.elementAt(index);
                    final maxAvalilable = product.order
                        + ((widget.editPrintFile != null &&
                            widget.editPrintFile!.productOnFile.containsKey(
                                product.code))
                            ? widget.editPrintFile!.productOnFile[product.code]!
                            : 0);
                    final isMaxAmount = _onFileProducts[product.code]! < maxAvalilable;
                    final isOverLimit = _onFileProducts[product.code]! > maxAvalilable;

                    return ListTile(
                      leading: product.imageUrl != null && product.imageUrl.isNotEmpty
                          ? CircleAvatar(
                        backgroundImage: NetworkImage(product.imageUrl),
                      ) : const CircleAvatar(
                        child: Icon(Icons.image_not_supported),
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${product.code} - ${product.type}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54)
                          ),
                          Text(
                              product.studio,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54)
                          ),
                        ],
                      ),
                      trailing: SizedBox(
                        //width: 150,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: amount == 1 ? Icon(Icons.delete, size: 16) : Text(
                                    '-',
                                    style: TextStyle(
                                      fontSize: 20,
                                    )
                                ),
                                onLongPress: () {
                                  setState(() {
                                    (_onFileProducts[product.code]! == 1)
                                        ? _removeProduct(product.code)
                                        : _onFileProducts[product.code] = 1;
                                  });
                                },onPressed: () {
                                setState(() {
                                  (_onFileProducts[product.code]! > 1)
                                      ? _onFileProducts[product.code] = _onFileProducts[product.code]! - 1
                                      : ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Segure para remover o produto totalmente.')),
                                  );
                                });
                              },
                              ),
                              SizedBox(
                                width: 47,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        amount.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isOverLimit && _orderLimit ? Colors.red : Colors.black,
                                          fontSize: 15,
                                        )
                                    ),
                                    Text('UNIDADE${amount > 1 ? 'S' : ''}', style: const TextStyle(fontSize: 9)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Text(
                                    '+',
                                    style: TextStyle(
                                      color: isMaxAmount ? Colors.black : Colors.grey,
                                      fontSize: 16,
                                    )
                                ),
                                onLongPress: () {
                                  setState(() {
                                    (_onFileProducts[product.code]! == maxAvalilable)
                                        ? _removeProduct(product.code)
                                        : _onFileProducts[product.code] = maxAvalilable;
                                  });
                                },
                                onPressed: isMaxAmount || !_orderLimit ? () {
                                  setState(() {
                                    if (_onFileProducts.containsKey(product.code))
                                      _onFileProducts[product.code] = _onFileProducts[product.code]! + 1;
                                    else
                                      _onFileProducts[product.code] = 1;
                                  });
                                } : null,
                              ),
                            ],
                        ),
                      )
                    );
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductSearchModal extends StatefulWidget {
  final ProductProvider productProvider;
  final PrintFile? editPrintFile;
  final Map<String, int> onFileProducts; // Passar a lista de produtos já adicionados
  final void Function(Product product) onProductSelected; // Callback para quando um produto é selecionado
  final bool orderLimit;

  const ProductSearchModal({
    Key? key,
    required this.productProvider,
    this.editPrintFile,
    required this.onFileProducts,
    required this.onProductSelected,
    required this.orderLimit,
  }) : super(key: key);

  @override
  _ProductSearchModalState createState() => _ProductSearchModalState();
}

class _ProductSearchModalState extends State<ProductSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    // Adiciona um listener ao controlador para atualizar o estado da pesquisa
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    // Remove o listener e descarta o controlador quando o widget é removido
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    // Atualiza a variável _searchText e reconstrói o widget
    setState(() {
      _searchText = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredListProduct = widget.productProvider.products.where((
        product) {
      final maxAvalilable = product.order +
          ((widget.editPrintFile != null &&
              widget.editPrintFile!.productOnFile.containsKey(product.code))
              ? widget.editPrintFile!.productOnFile[product.code]!
              : 0);
      bool isAvailable = widget.orderLimit ? (product.order > 0 &&
          (widget.onFileProducts.containsKey(product.code)
              ? widget.onFileProducts[product.code]! < maxAvalilable
              : true)) : true;

      if (_searchText.isNotEmpty) {
        final lowerCaseSearchText = _searchText.toLowerCase();
        final lowerCaseProductName = product.name.toLowerCase();
        final lowerCaseProductCode = product.code.toLowerCase();
        final lowerCaseProductType = product.type.toLowerCase();
        final lowerCaseProductStudio = product.studio.toLowerCase();

        return isAvailable && (
            lowerCaseProductName.contains(lowerCaseSearchText) ||
                lowerCaseProductCode.contains(lowerCaseSearchText) ||
                lowerCaseProductType.contains(lowerCaseSearchText) ||
                lowerCaseProductStudio.contains(lowerCaseSearchText)
        );
      }

      return isAvailable;
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery
          .of(context)
          .viewInsets
          .bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 10.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar Produto '
                    '(${filteredListProduct.length} encontrados)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none
                ),
              ),
              // O onChanged não é estritamente necessário aqui porque o listener já faz a atualização
              // onChanged: (value) { ... },
            ),
          ),
          const Divider(height: 0.0),
          Expanded(
            child: filteredListProduct.isEmpty
                ? Center(child: Text(_searchText.isNotEmpty
                ? 'Nenhum produto encontrado.'
                : 'Nenhum produto disponível.'))
                : ListView.builder(
              itemCount: filteredListProduct.length,
              itemBuilder: (context, index) {
                final product = filteredListProduct[index];
                final maxAvalilable = product.order +
                    ((widget.editPrintFile != null &&
                        widget.editPrintFile!.productOnFile.containsKey(
                            product.code))
                        ? widget.editPrintFile!.productOnFile[product.code]!
                        : 0);
                final available = '${widget.onFileProducts.containsKey(
                    product.code) ? '${maxAvalilable -
                    (widget.onFileProducts[product.code] ?? 0)}/' : ''}${maxAvalilable}';
                final subtitle = '${product.code} - ${product.type} (${product
                    .studio})';

                return InkWell(
                  onTap: () {
                    widget.onProductSelected(product); // Chama o callback
                    Navigator.of(context).pop();
                  },
                  child: ListTile(
                    leading: (product.imageUrl != null &&
                        product.imageUrl!.isNotEmpty && Uri
                        .tryParse(product.imageUrl!)
                        ?.hasAbsolutePath == true)
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(product.imageUrl!),
                    ) : const CircleAvatar(
                      child: Icon(Icons.image_not_supported),
                    ),
                    title: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        )
                    ),
                    subtitle: Text(
                        subtitle,
                        style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black54)
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            available,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              fontWeight: FontWeight.bold,

                            ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                            'unidade${maxAvalilable > 1 ? 's' : ''}\n em ordem',
                            style: const TextStyle(
                                fontSize: 9,
                                color: Colors.black38
                            ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}