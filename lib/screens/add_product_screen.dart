import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:atelier_manager/models/product_data.dart';
import 'package:provider/provider.dart';
import 'package:atelier_manager/providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studioController = TextEditingController();
  final TextEditingController _scaleController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _recommendedController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController(); // Controlador para a URL da imagem
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    _imageUrlController.addListener(_updateImageUrl);
  }

  @override
  void dispose() {
    _imageUrlController.removeListener(_updateImageUrl);
    _codeController.dispose();
    _nameController.dispose();
    _studioController.dispose();
    _scaleController.dispose();
    _typeController.dispose();
    _materialController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
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
      // A URL da imagem agora vem do campo de texto _imageUrlController
      _imageUrl = _imageUrlController.text;

      Product newProduct = Product(
        imageUrl: _imageUrl,
        code: _codeController.text,
        name: _nameController.text,
        studio: _studioController.text,
        scale: _scaleController.text,
        type: _typeController.text,
        material: _materialController.text,
        sellingPrice: double.parse(_sellingPriceController.text),
        stock: int.parse(_stockController.text),
        recommended: int.parse(_recommendedController.text),
      );

      // Use o 'code' como o ID do documento
      await FirebaseFirestore.instance
          .collection('products')
          .doc(_codeController.text) // Definindo o ID do documento
          .set(newProduct.toMap()); // Usando set para garantir que o documento seja criado ou sobrescrito
      Provider.of<ProductProvider>(context, listen: false).refreshProducts();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Adicionar Produto'),
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
    // Adicione uma validação mais robusta de URL se necessário
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
    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace){
    return _buildNoImagePlaceholder();
    },
    ),
    )
        : _buildNoImagePlaceholder(),
    const SizedBox(height: 20),
    TextFormField(
    controller: _codeController,
    decoration: const InputDecoration(labelText: 'Código'),
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
    controller: _stockController,
    decoration: const InputDecoration(labelText: 'Estoque'),
    keyboardType: TextInputType.number,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Por favor, insira o estoque';
    }
    if (int.tryParse(value) == null) {
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
        child: const Text('Salvar Produto'),
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