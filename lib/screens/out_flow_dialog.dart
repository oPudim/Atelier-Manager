import 'package:atelier_manager/models/product_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'package:intl/intl.dart';
import 'package:atelier_manager/models/out_flow_data.dart';

class OutFlowDialog extends StatefulWidget {
  final OutFlow? editOutFlow;

  const OutFlowDialog({Key? key, this.editOutFlow}) : super(key: key);

  @override
  _OutFlowDialogState createState() => _OutFlowDialogState();
}

class _OutFlowDialogState extends State<OutFlowDialog> {
  late ProductProvider productProvider;
  String? _selectedType;
  Map<String, int> _selectedProducts = {};
  Map<String, double> _selectedValues = {};
  DateTime _selectedDateTime = DateTime.now();
  Map<String, Object> _dataOutFlow = {};

  bool? isDataChanged = false;

  @override
  void initState() {
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    setState(() {
      if (widget.editOutFlow != null) {
        _selectedType = widget.editOutFlow!.type;
        _selectedProducts = widget.editOutFlow!.products.map(
              (key, value) => MapEntry(key, value),
        );
        _selectedValues = widget.editOutFlow!.prices.map(
              (key, value) => MapEntry(key, value),
        );
        _selectedDateTime = widget.editOutFlow!.dateTime;
        switch (widget.editOutFlow!.type) {
          case 'event':
            _dataOutFlow = {
              'eventId': (widget.editOutFlow! as EventOutFlow).eventId,
            };
            break;
          case 'order':
            _dataOutFlow = {
              'customerId': (widget.editOutFlow! as OrderOutFlow).customerId,
            };
            break;
          case 'marketplace':
            _dataOutFlow = {
              'platform': (widget.editOutFlow! as MarketplaceOutFlow).platform,
              'transactionId':
              (widget.editOutFlow! as MarketplaceOutFlow).transactionId,
            };
            break;
          case 'loss':
            _dataOutFlow = {
              'stage': (widget.editOutFlow! as LossOutFlow).stage,
              'reason': (widget.editOutFlow! as LossOutFlow).reason,
              'responsible':
              (widget.editOutFlow! as LossOutFlow).responsible ?? '',
            };
            break;
          case 'gift':
            _dataOutFlow = {
              'recipientId': (widget.editOutFlow! as GiftOutFlow).recipientId,
              'occasion': (widget.editOutFlow! as GiftOutFlow).occasion ?? '',
            };
            break;
          case 'barter':
            _dataOutFlow = {
              'partner': (widget.editOutFlow! as BarterOutFlow).partner,
              'itemsReceived':
              (widget.editOutFlow! as BarterOutFlow).itemsReceived,
            };
            break;
        }
      }
    });
    super.initState();
  }

  void _removeProduct(String productCode) {
    setState(() {
      _selectedProducts.remove(productCode);
      _selectedValues.remove(productCode);
    });
  }

  void _finalizePrint() {
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um produto para finalizar.'),
        ),
      );
      return;
    }
    Map<String, int> productsOutFlowToSave = {};
    Map<String, double> pricesOutFlowToSave = {};
    _selectedProducts.forEach((productCode, productAmount) {
      productsOutFlowToSave[productCode] = productAmount;
    });
    _selectedValues.forEach((productCode, productValue) {
      pricesOutFlowToSave[productCode] = productValue;
    });
    final eventOutFlow =
        _selectedType == 'event'
            ? EventOutFlow(
          id: '',
              dateTime: _selectedDateTime,
              products: productsOutFlowToSave,
              prices: pricesOutFlowToSave,
              eventId: _dataOutFlow['eventId'] as String,
            )
            : _selectedType == 'order'
            ? OrderOutFlow(
          id: '',
              dateTime: _selectedDateTime,
              products: productsOutFlowToSave,
              prices: pricesOutFlowToSave,
              customerId: _dataOutFlow['customerId'] as String,
            )
            : _selectedType == 'loss'
            ? LossOutFlow(
          id: '',
              dateTime: _selectedDateTime,
              products: productsOutFlowToSave,
              prices: pricesOutFlowToSave,
              stage: _dataOutFlow['stage'] == 'printed' ? LossStage.printed : LossStage.finished,
              reason: _dataOutFlow['reason'] as String,
              responsible: _dataOutFlow['responsible'] as String,
            )
            : _selectedType == 'gift'
            ? GiftOutFlow(
          id: '',
              dateTime: _selectedDateTime,
              products: productsOutFlowToSave,
              prices: pricesOutFlowToSave,
              recipientId: _dataOutFlow['recipientId'] as String,
              occasion: _dataOutFlow['occasion'] as String,
            )
            : _selectedType == 'barter'
            ? BarterOutFlow(
          id: '',
              dateTime: _selectedDateTime,
              products: productsOutFlowToSave,
              prices: pricesOutFlowToSave,
              partner: _dataOutFlow['partner'] as String,
              itemsReceived:
                  _dataOutFlow['itemsReceived'] as Map<String, double>,
            )
            : null;
    if (eventOutFlow == null) return;
    if (widget.editOutFlow == null) {
      productProvider.saveOutFlow(eventOutFlow);
      Navigator.of(context).pop();
    } else {
      isDataChanged = false;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirmar alteração da saída?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Alterar a data criará uma nova saída e excluirá a anterior.',
                ),
                if (widget.editOutFlow!.dateTime != _selectedDateTime)
                  Row(
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
                      Text('Alterar data.'),
                    ],
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (widget.editOutFlow!.dateTime != _selectedDateTime) {
                    if (isDataChanged == true) {
                      productProvider.saveOutFlow(eventOutFlow);
                      productProvider.deleteOutFlow(widget.editOutFlow!);
                    } else {
                      productProvider.updateOutFlow(
                          (_selectedType == 'event'
                              ? EventOutFlow(
                            id: widget.editOutFlow!.id,
                            dateTime: _selectedDateTime,
                            products: productsOutFlowToSave,
                            prices: pricesOutFlowToSave,
                            eventId: _dataOutFlow['eventId'] as String,
                          )
                              : _selectedType == 'order'
                              ? OrderOutFlow(
                            id: widget.editOutFlow!.id,
                            dateTime: _selectedDateTime,
                            products: productsOutFlowToSave,
                            prices: pricesOutFlowToSave,
                            customerId: _dataOutFlow['customerId'] as String,
                          )
                              : _selectedType == 'loss'
                              ? LossOutFlow(
                            id: widget.editOutFlow!.id,
                            dateTime: _selectedDateTime,
                            products: productsOutFlowToSave,
                            prices: pricesOutFlowToSave,
                            stage: _dataOutFlow['stage'] == 'printed' ? LossStage.printed : LossStage.finished,
                            reason: _dataOutFlow['reason'] as String,
                            responsible: _dataOutFlow['responsible'] as String,
                          )
                              : _selectedType == 'gift'
                              ? GiftOutFlow(
                            id: widget.editOutFlow!.id,
                            dateTime: _selectedDateTime,
                            products: productsOutFlowToSave,
                            prices: pricesOutFlowToSave,
                            recipientId: _dataOutFlow['recipientId'] as String,
                            occasion: _dataOutFlow['occasion'] as String,
                          )
                              : _selectedType == 'barter'
                              ? BarterOutFlow(
                            id: widget.editOutFlow!.id,
                            dateTime: _selectedDateTime,
                            products: productsOutFlowToSave,
                            prices: pricesOutFlowToSave,
                            partner: _dataOutFlow['partner'] as String,
                            itemsReceived:
                            _dataOutFlow['itemsReceived'] as Map<String, double>,
                          )
                              : null)!
                      );
                    }
                  } else {
                    productProvider.updateOutFlow(eventOutFlow);
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Confirmar'),
              ),
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
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('pt', 'BR'),
          child: child,
        );
      },
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime != null && pickedTime != _selectedDateTime) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
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
            editOutFlow: widget.editOutFlow,
            selectedProducts: _selectedProducts,
            selectedValues: _selectedValues,
            onProductSelected: (product) {
              setState(() {
                if (_selectedProducts.containsKey(product.code)) {
                  _selectedProducts[product.code] =
                      _selectedProducts[product.code]! + 1;
                } else {
                  _selectedProducts[product.code] = 1;
                }
                if (!_selectedValues.containsKey(product.code)) {
                  _selectedValues[product.code] = product.sellingPrice;
                }
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
        title: Text('${widget.editOutFlow == null ? 'Nova' : 'Editar'} saída'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _finalizePrint),
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
                    dropdownMenuEntries:
                        {
                              'event': 'Evento',
                              'order': 'Encomenda',
                              'marketplace': 'Marketplace',
                              'loss': 'Perda',
                              'gift': 'Brinde',
                              'barter': 'Escambo',
                            }.entries
                            .map(
                              (value) => DropdownMenuEntry(
                                value: value.key,
                                label: value.value,
                              ),
                            )
                            .toList(),
                    enableFilter: true,
                    requestFocusOnTap: true,
                    label: Text('Tipo de saída'),
                    inputDecorationTheme: const InputDecorationTheme(
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                    ),
                    onSelected: (String? value) {
                      setState(() {
                        _dataOutFlow = {};
                        _selectedType = value;
                      });
                    },
                  ),
                ),
                if (_selectedType != null) const SizedBox(width: 10),
                if (_selectedType == 'event' || _selectedType == 'loss')
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: DropdownMenu<String>(
                      dropdownMenuEntries:
                          _selectedType == 'event'
                              ? productProvider.events.map((events) {
                                return DropdownMenuEntry(
                                  value: events.id,
                                  label:
                                      '${events.name}\n${DateFormat('dd/MM/yyyy').format(events.startDate)} a ${DateFormat('dd/MM/yyyy').format(events.endDate)}',
                                );
                              }).toList()
                              : LossStage.values.map((stage) {
                                return DropdownMenuEntry(
                                  value: stage.toShortString(),
                                  label: stage.label(),
                                );
                              }).toList(),
                      enableFilter: true,
                      requestFocusOnTap: true,
                      label: Text(
                        _selectedType == 'event' ? 'Evento' : 'Etapa'
                      ),
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                      ),
                      onSelected: (String? value) {
                        setState(() {
                          if (_selectedType == 'event') {
                            _dataOutFlow['eventId'] = value as String;
                          } else {
                            _dataOutFlow['stage'] = value as String;
                          }
                        });
                      },
                    ),
                  ),
                if (_selectedType == 'order' || _selectedType == 'gift' || _selectedType == 'barter')
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: _selectedType == 'order' ? 'Cliente' : _selectedType == 'gift' ? 'Destinatário' : 'Parceiro',
                        border: UnderlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          switch (_selectedType) {
                            case 'order':
                              _dataOutFlow['customerId'] = value;
                              break;
                            case 'gift':
                              _dataOutFlow['recipientId'] = value;
                              break;
                            case 'barter':
                              _dataOutFlow['partner'] = value;
                              break;
                          }
                        });
                      }
                    ),
                  )
              ],
            ),
            if (_selectedType == 'loss' || _selectedType == 'gift')
              Column(
                children: [
                  const SizedBox(height: 5.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: _selectedType == 'loss' ? 'Motivo' : 'Ocasião',
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (_selectedType == 'loss')
                          _dataOutFlow['reason'] = value;
                        else
                          _dataOutFlow['occasion'] = value;
                      });
                    },
                  ),
                  if (_selectedType == 'loss')
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Responsável',
                        border: UnderlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _dataOutFlow['responsible'] = value;
                        });
                      },
                    ),
                ],
              ),
            if (_selectedType == 'barter')
              Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(height: 5.0),
                      Flexible(
                        flex: 2,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Itens recebidos',
                            border: UnderlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _dataOutFlow['itemsReceivedName'] = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        flex: 1,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Valor (R\$)',
                            border: UnderlineInputBorder(),
                            prefix: Text('R\$ '),
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _dataOutFlow['itemsReceivedValue'] = value
                                  .replaceAll(',', '.');
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.add_box),
                        onPressed:
                            (_dataOutFlow.containsKey('itemsReceivedName') &&
                                    _dataOutFlow.containsKey(
                                      'itemsReceivedValue',
                                    ) &&
                                    _dataOutFlow['itemsReceivedName'] != '' &&
                                    _dataOutFlow['itemsReceivedValue'] != '')
                                ? () {
                                  setState(() {
                                    if (_dataOutFlow.containsKey(
                                      'itemsReceived',
                                    )) {
                                      (_dataOutFlow['itemsReceived']
                                          as Map<
                                            String,
                                            double
                                          >)[_dataOutFlow['itemsReceivedName']
                                          as String] = double.parse(
                                        _dataOutFlow['itemsReceivedValue']
                                            as String,
                                      );
                                    } else {
                                      _dataOutFlow['itemsReceived'] = {
                                        _dataOutFlow['itemsReceivedName']
                                            as String: double.parse(
                                          _dataOutFlow['itemsReceivedValue']
                                              as String,
                                        ),
                                      };
                                    }
                                  });
                                }
                                : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  const Divider(height: 0.0),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                          _dataOutFlow.containsKey('itemsReceived')
                              ? (_dataOutFlow['itemsReceived']
                                      as Map<String, double>)
                                  .length
                              : 0,
                      itemBuilder: (context, index) {
                        final item = (_dataOutFlow['itemsReceived']
                                as Map<String, double>)
                            .entries
                            .elementAt(index);
                        return SizedBox(
                          height: 35,
                          child: ClipRect(
                            clipBehavior: Clip.hardEdge,
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child: Text(item.key),
                                ),
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Text(
                                    'R\$ ${item.value.toStringAsFixed(2).replaceAll('.', ',')}',
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      (_dataOutFlow['itemsReceived']
                                              as Map<String, double>)
                                          .remove(item.key);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(height: 0.0),
                  const SizedBox(height: 5.0),
                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: Text(
                          '${_dataOutFlow.containsKey('itemsReceived') ? (_dataOutFlow['itemsReceived'] as Map<String, double>).length : 0} ite${_dataOutFlow.containsKey('itemsReceived') && (_dataOutFlow['itemsReceived'] as Map<String, double>).length == 1 ? 'm' : 'ns'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Text(
                          'R\$ ${(_dataOutFlow.containsKey('itemsReceived') && (_dataOutFlow['itemsReceived'] as Map<String, double>).isNotEmpty ? (_dataOutFlow['itemsReceived'] as Map<String, double>).values.reduce((value, element) => value + element) : 0.0).toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48.0),
                    ],
                  ),
                ],
              ),
            Divider(),
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
                            '${DateFormat('dd/MM/yyyy').format(_selectedDateTime)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),
                      Icon(Icons.date_range, color: Colors.black, size: 22),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _selectedProducts.isEmpty
                      ? const Center(child: Text('Nenhum produto adicionado.'))
                      : ListView.builder(
                        itemCount: _selectedProducts.length,
                        itemBuilder: (context, index) {
                          final product = productProvider.findByCode(
                            _selectedProducts.keys.elementAt(index),
                          );
                          final amount = _selectedProducts.values.elementAt(
                            index,
                          );
                          final maxAvalilable =
                              product.numFinisheds +
                              ((widget.editOutFlow != null &&
                                      widget.editOutFlow!.products.containsKey(
                                        product.code,
                                      ))
                                  ? widget.editOutFlow!.products[product.code]!
                                  : 0);
                          final isMaxAmount =
                              _selectedProducts[product.code]! < maxAvalilable;

                          return ListTile(
                            leading:
                                product.imageUrl != null &&
                                        product.imageUrl.isNotEmpty
                                    ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        product.imageUrl,
                                      ),
                                    )
                                    : const CircleAvatar(
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
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  product.studio,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  'R\$ ${product.sellingPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
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
                                    icon:
                                        amount == 1
                                            ? Icon(Icons.delete, size: 16)
                                            : Text(
                                              '-',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                    onLongPress: () {
                                      setState(() {
                                        (_selectedProducts[product.code]! == 1)
                                            ? _removeProduct(product.code)
                                            : _selectedProducts[product.code] =
                                                1;
                                      });
                                    },
                                    onPressed: () {
                                      setState(() {
                                        (_selectedProducts[product.code]! > 1)
                                            ? _selectedProducts[product.code] =
                                                _selectedProducts[product
                                                    .code]! -
                                                1
                                            : ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Segure para remover o produto totalmente.',
                                                ),
                                              ),
                                            );
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 47,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          amount.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          'UNIDADE${amount > 1 ? 'S' : ''}',
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Text(
                                      '+',
                                      style: TextStyle(
                                        color:
                                            isMaxAmount
                                                ? Colors.black
                                                : Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                    onLongPress: () {
                                      setState(() {
                                        (_selectedProducts[product.code]! ==
                                                maxAvalilable)
                                            ? _removeProduct(product.code)
                                            : _selectedProducts[product.code] =
                                                maxAvalilable;
                                      });
                                    },
                                    onPressed:
                                        isMaxAmount
                                            ? () {
                                              setState(() {
                                                if (_selectedProducts
                                                    .containsKey(product.code))
                                                  _selectedProducts[product
                                                          .code] =
                                                      _selectedProducts[product
                                                          .code]! +
                                                      1;
                                                else
                                                  _selectedProducts[product
                                                          .code] =
                                                      1;
                                              });
                                            }
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                    padding: const EdgeInsets.only(bottom: 75.0),
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
  final OutFlow? editOutFlow;
  final Map<String, int> selectedProducts;
  final Map<String, double> selectedValues;
  final void Function(Product product) onProductSelected; // Callback para quando um produto é selecionado

  const ProductSearchModal({
    Key? key,
    required this.productProvider,
    this.editOutFlow,
    required this.selectedProducts,
    required this.selectedValues,
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
    final filteredListProduct =
        widget.productProvider.products.where((product) {
          final maxAvalilable =
              product.numFinisheds +
              ((widget.editOutFlow != null &&
                      widget.editOutFlow!.products.containsKey(product.code))
                  ? widget.editOutFlow!.products[product.code]!
                  : 0);
          bool isAvailable =
              product.numFinisheds > 0 &&
              (widget.selectedProducts.containsKey(product.code)
                  ? widget.selectedProducts[product.code]! < maxAvalilable
                  : true);

          if (_searchText.isNotEmpty) {
            final lowerCaseSearchText = _searchText.toLowerCase();
            final lowerCaseProductName = product.name.toLowerCase();
            final lowerCaseProductCode = product.code.toLowerCase();
            final lowerCaseProductType = product.type.toLowerCase();
            final lowerCaseProductStudio = product.studio.toLowerCase();

            return isAvailable &&
                (lowerCaseProductName.contains(lowerCaseSearchText) ||
                    lowerCaseProductCode.contains(lowerCaseSearchText) ||
                    lowerCaseProductType.contains(lowerCaseSearchText) ||
                    lowerCaseProductStudio.contains(lowerCaseSearchText));
          }

          return isAvailable;
        }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText:
                    'Pesquisar Produto '
                    '(${filteredListProduct.length} encontrados)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              // O onChanged não é estritamente necessário aqui porque o listener já faz a atualização
              // onChanged: (value) { ... },
            ),
          ),
          const Divider(height: 0.0),
          Expanded(
            child:
                filteredListProduct.isEmpty
                    ? Center(
                      child: Text(
                        _searchText.isNotEmpty
                            ? 'Nenhum produto encontrado.'
                            : 'Nenhum produto disponível.',
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredListProduct.length,
                      itemBuilder: (context, index) {
                        final product = filteredListProduct[index];
                        final maxAvalilable =
                            product.numFinisheds +
                            ((widget.editOutFlow != null &&
                                    widget.editOutFlow!.products.containsKey(
                                      product.code,
                                    ))
                                ? widget.editOutFlow!.products[product.code]!
                                : 0);
                        final available =
                            '${widget.selectedProducts.containsKey(product.code) ? '${maxAvalilable - (widget.selectedProducts[product.code] ?? 0)}/' : ''}'
                            '${maxAvalilable} unidade${maxAvalilable > 1 ? 's' : ''}';
                        final subtitle =
                            '${product.code} - ${product.type} (${product.studio})';

                        return InkWell(
                          onTap: () {
                            widget.onProductSelected(
                              product,
                            ); // Chama o callback
                            Navigator.of(context).pop();
                          },
                          child: ListTile(
                            leading:
                                (product.imageUrl != null &&
                                        product.imageUrl.isNotEmpty &&
                                        Uri.tryParse(
                                              product.imageUrl,
                                            )?.hasAbsolutePath ==
                                            true)
                                    ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        product.imageUrl,
                                      ),
                                    )
                                    : const CircleAvatar(
                                      child: Icon(Icons.image_not_supported),
                                    ),
                            title: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
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
