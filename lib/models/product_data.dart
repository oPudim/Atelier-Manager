import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String imageUrl;
  final String code; // Agora o 'code' é o identificador principal
  final String name;
  final String studio;
  final String scale;
  final String type;
  final String material;
  final double sellingPrice;
  final int stock;
  final int recommended;

  Product({
    required this.imageUrl,
    required this.code,
    required this.name,
    required this.studio,
    required this.scale,
    required this.type,
    required this.material,
    required this.sellingPrice,
    required this.stock,
    required this.recommended,
  });

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'code': code,
      'name': name,
      'studio': studio,
      'scale': scale,
      'type': type,
      'material': material,
      'sellingPrice': sellingPrice,
      'stock': stock,
      'recommended': recommended,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      imageUrl: map['imageUrl'] ?? '',
      code: map['code'] ?? '', // Usamos o 'code' como identificador
      name: map['name'] ?? '',
      studio: map['studio'] ?? '',
      scale: map['scale'].toString() ?? '',
      type: map['type'] ?? '',
      material: map['material'] ?? '',
      sellingPrice: (map['sellingPrice'] != null) ? map['sellingPrice'].toDouble() : 0.0,
      stock: (map['stock'] != null) ? map['stock'].toInt() : 0,
      recommended: (map['recommended'] != null) ? map['recommended'].toInt() : 0,
    );
  }
}