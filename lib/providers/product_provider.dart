import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:atelier_manager/models/product_data.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> get products => _products;

  ProductProvider() {
    _listenToProducts();
  }

  void _listenToProducts() {
    FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen((snapshot) {
      _products = snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
      notifyListeners();
    });
  }

  Future<void> refreshProducts() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('products').get();
    _products = snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
    notifyListeners();
  }
}