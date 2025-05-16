import 'package:atelier_manager/widgets/main_drawer.dart';
import 'add_product_screen.dart';
import 'package:atelier_manager/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atelier_manager/models/product_data.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Widget _productPictureFrame(ProductProvider productProvider, String product) {
    final productData = productProvider.findByCode(product);
    return Stack(
      children: [
        Container(
          height: 100,
          width: 100,
          margin: const EdgeInsets.only(
            bottom: 10,
            left: 10,
            right: 10,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              productData.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return ColoredBox(
                  color: Colors.black12,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return const ColoredBox(
                  color: Colors.black12,
                  child: Center(child: Icon(Icons.error)),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 60.8,
          left: 1.2,
          child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.lightBlueAccent,
              child: Text(productData.numOnFiles.toString(),
                  style: TextStyle(
                      color: productData.numOnFiles > 0 ? Colors.white : Colors.white10,
                      fontWeight: FontWeight.bold,
                      fontSize: 10
                  ))),
        ),
        Positioned(
          bottom: 39.2,
          left: 1.2,
          child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.orangeAccent,
              child: Text(productData.numPrinteds.toString(),
                  style: TextStyle(
                      color: productData.numPrinteds > 0 ? Colors.white : Colors.white10,
                      fontWeight: FontWeight.bold,
                      fontSize: 10
                  ))),
        ),
        Positioned(
          bottom: 8.6,
          left: 8.6,
          child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.deepPurpleAccent,
              child: Text(productData.numFinisheds.toString(),
                  style: TextStyle(
                      color: productData.numFinisheds > 0 ? Colors.white : Colors.white10,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                  ))),
        ),
      ],
    );
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    if (_searchQuery.isEmpty) {
      return products;
    } else {
      return products.where((product) => product.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
  }

  Widget _productCard (ProductProvider productProvider, Product product) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 15.0,
          left: 15.0,
          right: 15.0,
          bottom: 5.0
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _productPictureFrame(productProvider, product.code),
          const SizedBox(width: 10),
          SizedBox(
            height: 100,
            width: 230,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maxLines: 2,
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      product.code,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(product.scale).toStringAsFixed(product.scale.truncateToDouble() == product.scale ? 0 : 1).replaceAll('.', ',')}%',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black26
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.type,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54
                          ),
                        ),
                        Text(
                          '${product.studio}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black26
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                      height: 25,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.5),
                        color: Colors.black12,
                      ),
                      child: Center(
                        child: Text(
                          'R\$ ${product.sellingPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text('Produtos'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductScreen(),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          List<Product> filteredProducts = _getFilteredProducts(productProvider.products);
          if (filteredProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(height: 0.0),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                Product product = filteredProducts[index];
                return InkWell(
                  onDoubleTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(product: product),
                      ),
                    );
                  },
                  child: _productCard(productProvider, product),
                );
              },
            );
          }
        },
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