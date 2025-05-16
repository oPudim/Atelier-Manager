import 'package:atelier_manager/models/product_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'package:intl/intl.dart';

class FinishDialog extends StatefulWidget {
  final Finished? editFinished;

  const FinishDialog({Key? key, this.editFinished}) : super(key: key);

  @override
  _FinishDialogState createState() => _FinishDialogState();
}

class _FinishDialogState extends State<FinishDialog> {

  late ProductProvider productProvider;
  Map<String, int> _addedProducts = {};
  DateTime _selectedDate = DateTime.now();

  bool? isDataChanged = false;

  @override
  void initState() {
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    if (widget.editFinished != null) {
      setState(() {
        _addedProducts = widget.editFinished!.products.map((key, value) => MapEntry(key, value));
        _selectedDate = widget.editFinished!.dateTime;
      });
    }
    super.initState();
  }

  void _removeProduct(String productCode) {
    setState(() {
      _addedProducts.remove(productCode);
    });
  }

  void _finalizeFinish() {
    if (_addedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um produto para finalizar.'),
        ),
      );
      return;
    }
    Map<String, int> productsToSave = {};
    _addedProducts.forEach((productCode, productAmount) {
      productsToSave[productCode] = productAmount;
    });
    final newFinish = Finished(
      id: '',
      dateTime: _selectedDate,
      products: productsToSave,
    );
    if (widget.editFinished == null) {
      productProvider.saveFinished(newFinish);
      Navigator.of(context).pop();
    } else {
      isDataChanged = false;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirmar alteração da finalização?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Alterar a data criará uma nova finalização e excluirá a anterior.'),
                if (widget.editFinished!.dateTime != _selectedDate) Row(
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
                if (widget.editFinished!.dateTime != _selectedDate) {
                  if (isDataChanged == true) {
                    productProvider.saveFinished(newFinish);
                    productProvider.deleteFinished(widget.editFinished!);
                  } else {
                    productProvider.updateFinished(Finished(
                        id: widget.editFinished!.id,
                        dateTime: widget.editFinished!.dateTime,
                        products: productsToSave
                    ));}
                } else {
                  productProvider.updateFinished(newFinish);
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      locale: const Locale('pt', 'BR'),
      context: context,
      initialDate: _selectedDate,
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
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (pickedTime != null && pickedTime != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime?.hour ?? _selectedDate.hour,
          pickedTime?.minute ?? _selectedDate.minute,
        ).toUtc();
      });
    }
  }

  void _buildSuggestions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o modal ocupe mais espaço (útil para a lista)
      builder: (context) {
        return SizedBox(
          height: 500,
          child: ProductSearchModal(
            productProvider: productProvider,
            editFinished: widget.editFinished,
            addedProducts: _addedProducts, // Passa os produtos já adicionados
            onProductSelected: (product) { // Callback para lidar com a seleção de produto
              setState(() { // Atualiza o estado do _PrintDialogState
                if (_addedProducts.containsKey(product.code)) {
                  _addedProducts[product.code] = _addedProducts[product.code]! + 1;
                } else {
                  _addedProducts[product.code] = 1;
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
        title: Text('${widget.editFinished == null ? 'Nova' : 'Editar'} finalização'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _finalizeFinish,
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
                  onPressed: () => _selectDate(context),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${DateFormat('HH:mm').format(_selectedDate)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),
                      Icon(Icons.date_range, color: Colors.black, size: 22)
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _addedProducts.isEmpty
                  ? const Center(child: Text('Nenhum produto adicionado ainda.'))
                  : ListView.builder(
                itemCount: _addedProducts.length,
                itemBuilder: (context, index) {
                  final product = productProvider.findByCode(_addedProducts.keys.elementAt(index));
                  final amount = _addedProducts.values.elementAt(index);
                  final maxAvalilable = product.numPrinteds
                      + ((widget.editFinished != null && widget.editFinished!.products.containsKey(product.code))
                          ? widget.editFinished!.products[product.code]! : 0);
                  final isMaxAmount = _addedProducts[product.code]! < maxAvalilable;

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
                        )
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
                                (_addedProducts[product.code]! == 1)
                                    ? _removeProduct(product.code)
                                    : _addedProducts[product.code] = 1;
                              });
                            },
                            onPressed: () {
                              setState(() {
                                (_addedProducts[product.code]! > 1)
                                    ? _addedProducts[product.code] = _addedProducts[product.code]! - 1
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
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
                                _addedProducts[product.code] = productProvider.findByCode(product.code).numPrinteds;
                              });
                            },
                            onPressed: () {
                              setState(() {
                                if (isMaxAmount) _addedProducts[product.code] = _addedProducts[product.code]! + 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProductSearchModal extends StatefulWidget {
  final ProductProvider productProvider;
  final Finished? editFinished;
  final Map<String, int> addedProducts; // Passar a lista de produtos já adicionados
  final void Function(Product product) onProductSelected; // Callback para quando um produto é selecionado

  const ProductSearchModal({
    Key? key,
    required this.productProvider,
    this.editFinished,
    required this.addedProducts,
    required this.onProductSelected,
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
      final maxAvalilable = product.numPrinteds +
          ((widget.editFinished != null &&
              widget.editFinished!.products.containsKey(product.code))
              ? widget.editFinished!.products[product.code]!
              : 0);
      bool isAvailable = product.numPrinteds > 0 &&
          (widget.addedProducts.containsKey(product.code)
              ? widget.addedProducts[product.code]! < maxAvalilable
              : true);

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
                final maxAvalilable = product.numPrinteds +
                    ((widget.editFinished != null &&
                        widget.editFinished!.products.containsKey(
                            product.code))
                        ? widget.editFinished!.products[product.code]!
                        : 0);
                final available = '${widget.addedProducts.containsKey(
                    product.code) ? '${maxAvalilable -
                    (widget.addedProducts[product.code] ?? 0)}/' : ''}'
                    '${maxAvalilable} unidade${maxAvalilable > 1 ? 's' : ''}';
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
                            fontSize: 10,
                            color: Colors.black54)
                    ),
                    trailing: Text(available),
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