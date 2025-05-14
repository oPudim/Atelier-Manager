import 'edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:atelier_manager/models/product_data.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Produto - ${product.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProductScreen(product: product),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return _buildNoImagePlaceholder();
                    },
                  )
                      : _buildNoImagePlaceholder(),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Código', product.code),
              _buildDetailRow('Nome', product.name),
              _buildDetailRow('Estúdio', product.studio),
              _buildDetailRow('Escala', product.scale.toString()),
              _buildDetailRow('Tipo', product.type),
              _buildDetailRow('Material', product.material),
              _buildDetailRow('Preço de Venda', 'R\$ ${product.sellingPrice.toStringAsFixed(2)}'),
              _buildDetailRow('Estoque', '${product.numFinisheds}'),
              _buildDetailRow('Recomendado', '${product.recommended}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, overflow: TextOverflow.ellipsis, softWrap: true),
          ),
        ],
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