import 'package:cloud_firestore/cloud_firestore.dart';

class PrintProduct {
  String code;
  int amount;
  int failures;

  PrintProduct({
    required this.code,
    required this.amount,
    this.failures = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'amount': amount,
      'failures': failures,
    };
  }

  factory PrintProduct.fromMap(Map<String, dynamic> map) {
    return PrintProduct(
      code: map['code'],
      amount: map['amount'],
      failures: map['failures'] ?? 0,
    );
  }
}

class Print {
  String? id;
  DateTime dateTime;
  String file;
  String printer;
  List<PrintProduct> products;

  Print({
    this.id,
    required this.dateTime,
    required this.file,
    required this.printer,
    required this.products,
  });

  Map<String, dynamic> toMap() {
    return {
      'dateTime': Timestamp.fromDate(dateTime),
      'file': file,
      'printer': printer,
      'products': products.map((product) => product.toMap()).toList(),
    };
  }

  factory Print.fromMap(Map<String, dynamic> map, String id) {
    Timestamp? timestamp = map['dateTime'] as Timestamp?;
    DateTime dateTime = timestamp?.toDate() ?? DateTime.now();
    List<dynamic> productsData = map['products'] ?? [];
    List<PrintProduct> printProducts = productsData.map((item) => PrintProduct.fromMap(item)).toList();
    return Print(
      id: id,
      dateTime: dateTime,
      file: map['file'],
      printer: map['printer'],
      products: printProducts,
    );
  }
}