import 'package:cloud_firestore/cloud_firestore.dart';
import 'out_flow_data.dart';

class Product {
  final String imageUrl;
  final String code; // Agora o 'code' é o identificador principal
  final String name;
  final String studio;
  final double scale;
  final String type;
  final String material;
  final double sellingPrice;
  final int recommended;

  int numOnFiles = 0;
  int numPrinteds = 0;
  late int numFinisheds;
  late int numOutflows;
  late int numSales;
  late double earnings;

  int prevision = 0;
  int order = 0;

  Product({
    required this.imageUrl,
    required this.code,
    required this.name,
    required this.studio,
    required this.scale,
    required this.type,
    required this.material,
    required this.sellingPrice,
    required this.recommended,
  }) {

  }

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
      'recommended': recommended,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      imageUrl: map['imageUrl'] ?? '',
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      studio: map['studio'] ?? '',
      scale: (map['scale'] as num?)?.toDouble() ?? -1.0,
      type: map['type'] ?? '',
      material: map['material'] ?? '',
      sellingPrice: (map['sellingPrice'] as num?)?.toDouble() ?? -1.0,
      recommended: map['recommended'] ?? -1,
    );
  }
}

class Finished {
  final DateTime dateTime;
  final Map<String, int> products;

  Finished({
    required this.dateTime,
    required this.products,
  });

  Map<String, dynamic> toMap() {
    return {
      'dateTime': Timestamp.fromDate(dateTime),
      'products': products,
    };
  }

  factory Finished.fromMap(Map<String, dynamic> map) {
    DateTime _DateTime;
    final _DateTimeValue = map['dateTime'];

    if (_DateTimeValue is Timestamp) {
      _DateTime = _DateTimeValue.toDate();
    } else if (_DateTimeValue is String) {
      try {
        _DateTime = DateTime.parse(_DateTimeValue);
      } catch (e) {
        print('Erro ao parsear fileDateTime como String "$_DateTimeValue" (esperado ISO 8601): $e');
        _DateTime = DateTime.now();
      }
    } else {
      print('fileDateTime com tipo inesperado: ${_DateTimeValue.runtimeType}. Valor: $_DateTimeValue. Usando data/hora atual como fallback.');
      _DateTime = DateTime.now();
    }
    return Finished(
      dateTime: _DateTime,
      products: (map['products'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value as int)) ?? {},
    );
  }
}

class PrintFile {
  final DateTime fileDateTime;
  final DateTime printDateTime;
  final String fileName;
  final String printerName;
  final Map<String, int> productOnFile;
  final Map<String, int> productPrinted;
  late bool isPrinted;

  PrintFile({
    required this.fileDateTime,
    required this.printDateTime,
    required this.fileName,
    required this.printerName,
    required this.productOnFile,
    required this.productPrinted,
  }) {
    isPrinted = (fileDateTime != printDateTime);
  }

  Map<String, dynamic> toMap() {
    return {
      'fileDateTime': Timestamp.fromDate(fileDateTime),
      'printDateTime': Timestamp.fromDate(printDateTime),
      'fileName': fileName,
      'printerName': printerName,
      'productOnFile': productOnFile,
      'productPrinted': productPrinted,
    };
  }

  factory PrintFile.fromMap(Map<String, dynamic> map) {
    DateTime fileDateTime;
    final fileDateTimeValue = map['fileDateTime'];

    if (fileDateTimeValue is Timestamp) {
      fileDateTime = fileDateTimeValue.toDate();
    } else if (fileDateTimeValue is String) {
      try {
        // Use DateTime.parse() para strings ISO 8601
        fileDateTime = DateTime.parse(fileDateTimeValue);
      } catch (e) {
        // Se o parse falhar (string não é um ISO 8601 válido)
        print('Erro ao parsear fileDateTime como String "$fileDateTimeValue" (esperado ISO 8601): $e');
        // Trate o erro - por exemplo, defina uma data padrão
        fileDateTime = DateTime.now(); // Ou DateTime(1970) ou outro fallback
      }
    } else {
      // Trate outros tipos inesperados
      print('fileDateTime com tipo inesperado: ${fileDateTimeValue.runtimeType}. Valor: $fileDateTimeValue. Usando data/hora atual como fallback.');
      fileDateTime = DateTime.now();
    }

    DateTime printDateTime;
    final printDateTimeValue = map['printDateTime'];
    if (printDateTimeValue is Timestamp) {
      printDateTime = printDateTimeValue.toDate();
    } else if (printDateTimeValue is String) {
      try {
        // Use DateTime.parse() para strings ISO 8601
        printDateTime = DateTime.parse(printDateTimeValue);
      } catch (e) {
        print('Erro ao parsear printDateTime como String "$printDateTimeValue" (esperado ISO 8601): $e');
        printDateTime = DateTime.now();
      }
    } else {
      print('printDateTime com tipo inesperado: ${printDateTimeValue.runtimeType}. Valor: $printDateTimeValue. Usando data/hora atual como fallback.');
      printDateTime = DateTime.now();
    }

    return PrintFile(
      fileDateTime: fileDateTime,
      printDateTime: printDateTime,
      fileName: map['fileName'] ?? '',
      printerName: map['printerName'] ?? '',
      productOnFile: (map['productOnFile'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value as int)) ?? {},
      productPrinted: (map['productPrinted'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value as int)) ?? {},
    );
  }
}

