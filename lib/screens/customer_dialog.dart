import 'package:flutter/material.dart';
import 'package:atelier_manager/models/out_flow_data.dart';
import 'package:atelier_manager/providers/product_provider.dart';


class CustomerDialog extends StatefulWidget {
  final Customer? editCustomer;

  const CustomerDialog({Key? key, this.editCustomer}) : super(key: key);

  @override
  _CustomerDialogState createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<CustomerDialog> {
  ProductProvider _productProvider = ProductProvider();
  String _name = '';
  String _cpf = '';
  String _contact = '';
  String _phoneNumber = '';
  String _address = '';
  String _cep = '';
  String _observations = '';

  @override
  void initState() {
    if (widget.editCustomer != null) {
      _name = widget.editCustomer!.name;
      _cpf = widget.editCustomer!.cpf ?? '';
      _contact = widget.editCustomer!.contact ?? '';
      _phoneNumber = widget.editCustomer!.phoneNumber ?? '';
      _address = widget.editCustomer!.address ?? '';
      _cep = widget.editCustomer!.cep ?? '';
      _observations = widget.editCustomer!.observations ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.editCustomer != null ? 'Editar' : 'Novo'} cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final newCustomer = Customer(
                id: widget.editCustomer != null ? widget.editCustomer!.id : '',
                name: _name,
                outFlows: [],
              );
              widget.editCustomer != null
                  ? _productProvider.updateCustomer(newCustomer)
                  : _productProvider.saveCustomer(newCustomer);
              Navigator.pop(context);
            },
          ),
        ]
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nome'),
              controller: TextEditingController(text: _name),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'CPF'),
              controller: TextEditingController(text: _cpf),
              onChanged: (value) {
                setState(() {
                  _cpf = value;
                  });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Contato'),
              controller: TextEditingController(text: _contact),
              onChanged: (value) {
                setState(() {
                  _contact = value;
                  });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Telefone'),
                controller: TextEditingController(text: _phoneNumber),
                onChanged: (value) {
                setState(() {
                  _phoneNumber = value;
                  });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Endereço'),
              controller: TextEditingController(text: _address),
              onChanged: (value) {
                setState(() {
                  _address = value;
                  });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'CEP'),
                controller: TextEditingController(text: _cep),
                onChanged: (value) {
                setState(() {
                  _cep = value;
                  });
              },
                ),
            TextField(
              decoration: const InputDecoration(labelText: 'Observações'),
              controller: TextEditingController(text: _observations),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _observations = value;
                  });
                },
            ),
          ]
        )
      ),
    );
  }
}