import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:atelier_manager/models/product_data.dart';
import 'package:provider/provider.dart';
import 'package:atelier_manager/providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _studioController;
  late final TextEditingController _scaleController;
  late final TextEditingController _typeController;
  late final TextEditingController _materialController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _recommendedController;
  late final TextEditingController _imageUrlController;
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    // Inicialize os controladores com os valores do produto
    _codeController = TextEditingController(text: widget.product.code);
    _nameController = TextEditingController(text: widget.product.name);
    _studioController = TextEditingController(text: widget.product.studio);
    _scaleController = TextEditingController(text: widget.product.scale.toString());
    _typeController = TextEditingController(text: widget.product.type);
    _materialController = TextEditingController(text: widget.product.material);
    _sellingPriceController = TextEditingController(text: widget.product.sellingPrice.toString());
    _recommendedController = TextEditingController(text: widget.product.recommended.toString());
    _imageUrlController = TextEditingController(text: widget.product.imageUrl);
    _imageUrl = widget.product.imageUrl;
    _imageUrlController.addListener(_updateImageUrl);
  }

  @override
  void dispose() {
    _imageUrlController.removeListener(_updateImageUrl);
    // Descarte os controladores quando não forem mais necessários
    _codeController.dispose();
    _nameController.dispose();
    _studioController.dispose();
    _scaleController.dispose();
    _typeController.dispose();
    _materialController.dispose();
    _sellingPriceController.dispose();
    _recommendedController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    setState(() {
      _imageUrl = _imageUrlController.text;
    });
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      // Atualize o produto com os novos valores
      Product updatedProduct = Product(
        id: widget.product.id,
        imageUrl: _imageUrlController.text,
        code: _codeController.text,
        name: _nameController.text,
        studio: _studioController.text,
        scale: double.parse(_scaleController.text),
        type: _typeController.text,
        material: _materialController.text,
        sellingPrice: double.parse(_sellingPriceController.text),
        recommended: int.parse(_recommendedController.text),
      );

      // Use o 'code' como o ID do documento para atualizar
      await FirebaseFirestore.instance
          .collection('products')
          .doc(_codeController.text) // Definindo o ID do documento
          .set(updatedProduct.toMap()); // Usando set para garantir que o documento seja atualizado

      Navigator.pop(context); // Navega de volta para a tela anterior (ProductDetailsScreen)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo para a URL da imagem
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL da Imagem'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a URL da imagem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Visualização da imagem
              _imageUrl.isNotEmpty
                  ? Container(
                width: 100,
                height: 100,
                child: Image.network(
                  _imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return _buildNoImagePlaceholder();
                  },
                ),
              )
                  : _buildNoImagePlaceholder(),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Código'),
                enabled: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o código';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _studioController,
                decoration: const InputDecoration(labelText: 'Estúdio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o estúdio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _scaleController,
                decoration: const InputDecoration(labelText: 'Escala'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a escala';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Tipo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o tipo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _materialController,
                decoration: const InputDecoration(labelText: 'Material'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o material';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sellingPriceController,
                decoration: const InputDecoration(labelText: 'Preço de Venda'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço de venda';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _recommendedController,
                decoration: const InputDecoration(labelText: 'Recomendado'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o recomendado';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildNoImagePlaceholder() {
    return Container(
      color: Colors.grey[200], // Fundo cinza claro
      child: const Center(
        child: Text(
          'Sem Imagem',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}