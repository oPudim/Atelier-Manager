import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:atelier_manager/models/product_data.dart';
import 'package:atelier_manager/models/out_flow_data.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<PrintFile>_printFiles = [];
  List<Finished> _finisheds = [];
  List<String> _fileNames = [];
  List<String> _printerNames = [];
  List<Product> get products => _products;
  List<PrintFile> get printFiles => _printFiles;
  List<Finished> get finisheds => _finisheds;
  List<String> get fileNames => _fileNames;
  List<String> get printerNames => _printerNames;

  List<Event> _events = [];
  List<Customer> _customers = [];
  List<OutFlow> _outFlows = [];
  List<Event> get events => _events;
  List<Customer> get customers => _customers;
  List<OutFlow> get outFlows => _outFlows;

  ProductProvider() {
    _listenToProducts();
  }

  void _listenToProducts() {
    FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen((snapshot) {
      _products = snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList()
        ..sort((a, b) => a.code.compareTo(b.code));
      calculateProductsInfo();
    });
    FirebaseFirestore.instance
        .collection('printFiles')
        .snapshots()
        .listen((snapshot) {
      _printFiles =
          snapshot.docs.map((doc) => PrintFile.fromMap(doc.data(), doc.id)).toList()
            ..sort((a, b) => a.fileDateTime.compareTo(b.fileDateTime));
      calculateProductsInfo();
    });
    FirebaseFirestore.instance
        .collection('finisheds')
        .snapshots()
        .listen((snapshot) {
      _finisheds =
          snapshot.docs.map((doc) => Finished.fromMap(doc.data(), doc.id)).toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      calculateProductsInfo();
    });
    FirebaseFirestore.instance
        .collection('events')
        .snapshots()
        .listen((snapshot) {
      _events = snapshot.docs.map((doc) => Event.fromMap(doc.data(), doc.id)).toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
      calculateProductsInfo();
    });
    FirebaseFirestore.instance
        .collection('customers')
        .snapshots()
        .listen((snapshot) {
      _customers = snapshot.docs.map((doc) => Customer.fromMap(doc.data())).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      calculateProductsInfo();
    });
    FirebaseFirestore.instance
        .collection('outFlows')
        .snapshots()
        .listen((snapshot) {
      _outFlows = snapshot.docs.map((doc) => OutFlow.fromMap(doc.data(), doc.id)).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      calculateProductsInfo();
    });
    calculateProductsInfo();
  }

  Product findByCode(String code) {
    return _products.firstWhere((product) => product.code == code);
  }

  Event findByEventId(String eventId) {
    return _events.firstWhere((event) => event.id == eventId);
  }

  Future<void> calculateProductsInfo () async {
    _products.forEach((product) {
      int totalOnFile = 0;
      int totalPrinted = 0;
      int totalFinished = 0;
      int totalOutFlow = 0;
      int totalSales = 0;
      double totalEarnings = 0.0;
      double totalEarningsThisMonth = 0.0;
      double totalEarningsThisYear = 0.0;

      _printFiles.forEach((printFile) {
        if (printFile.isPrinted) {
          if (printFile.productPrinted.containsKey(product.code)) {
            totalPrinted += printFile.productPrinted[product.code]!;
          }
        } else {
          if (printFile.productOnFile.containsKey(product.code)) {
            totalOnFile += printFile.productOnFile[product.code]!;
          }
        }
      });
      _finisheds.forEach((finished) {
        if (finished.products.containsKey(product.code)) {
          totalFinished += finished.products[product.code]!;
          totalPrinted -= finished.products[product.code]!;
        }
      });
      _outFlows.forEach((outFlow) {
        if (outFlow.products.containsKey(product.code)) {
          totalOutFlow += outFlow.products[product.code]!;
          totalFinished -= outFlow.products[product.code]!;
          if (outFlow.isSale) {
            totalSales += outFlow.products[product.code]!;
            totalEarnings += outFlow.products[product.code]! * outFlow.prices[product.code]!;
            if (outFlow.dateTime.year == DateTime.now().year) {
              totalEarningsThisYear += outFlow.products[product.code]! * outFlow.prices[product.code]!;
              if (outFlow.dateTime.month == DateTime.now().month) {
                totalEarningsThisMonth += outFlow.products[product.code]! * outFlow.prices[product.code]!;
              }
            }
          }
        }
      });

      product.numOnFiles = totalOnFile;
      product.numPrinteds = totalPrinted;
      product.numFinisheds = totalFinished;
      product.numOutflows = totalOutFlow;
      product.numSales = totalSales;
      product.earnings = totalEarnings;
      product.earningsThisMonth = totalEarningsThisMonth;
      product.earningsThisYear = totalEarningsThisYear;
      product.prevision = product.numOnFiles + product.numPrinteds + product.numFinisheds;
      product.order = product.prevision < product.recommended ? product.recommended - product.prevision : 0;
    });
    _printFiles.forEach((printFile) {
      if (!_fileNames.contains(printFile.fileName)) _fileNames.add(printFile.fileName);
      if (!_printerNames.contains(printFile.printerName)) _printerNames.add(printFile.printerName);
    });
    notifyListeners();
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //PrintFiles functions

  Future<void> savePrint(PrintFile printFile) async {
    await FirebaseFirestore.instance.collection('printFiles')
        .add(printFile.toMap());
  }

  Future<void> updatePrint(PrintFile printFile) async {
    print(printFile.fileDateTime.toIso8601String().substring(0,23));
    await FirebaseFirestore.instance.collection('printFiles')
        .doc(printFile.id)
        .update(printFile.toMap());
  }

  Future<void> deletePrint(PrintFile printFile) async {
    await FirebaseFirestore.instance.collection('printFiles')
        .doc(printFile.id)
        .delete();
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //Events functions

  Future<void> saveEvent(Event event) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .add(event.toMap());
      print('Evento salvo com sucesso: ${event.name}');
    } catch (e) {
      print('Erro ao salvar evento: $e');
      throw e;
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .update(event.toMap());
      print('Evento atualizado com sucesso: ${event.name}');
    } catch (e) {
      print('Erro ao atualizar evento: $e');
      throw e;
    }
  }

  Future<void> deleteEvent(Event event) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .delete();
      print('Evento excluído com sucesso: ${event.name}');
    } catch (e) {
      print('Erro ao excluir evento: $e');
      throw e;
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //OutFlows functions

  Future<void> saveOutFlow(OutFlow outFlow) async {
    try {
      await FirebaseFirestore.instance
          .collection('outFlows')
          .add(outFlow.toMap());
      print('Saída salva com sucesso: ${outFlow.type}');
    } catch (e) {
      print('Erro ao salvar saída: $e');
      throw e;
    }
  }

  Future<void> updateOutFlow(OutFlow outFlow) async {
    try {
      await FirebaseFirestore.instance
          .collection('outFlows')
          .doc(outFlow.id)
          .update(outFlow.toMap());
      print('Saída atualizada com sucesso: ${outFlow.type}');
    } catch (e) {
      print('Erro ao atualizar saída: $e');
      throw e;
    }
  }

  Future<void> deleteOutFlow(OutFlow outFlow) async {
    try {
      await FirebaseFirestore.instance
          .collection('outFlows')
          .doc(outFlow.id)
          .delete();
      print('Saída excluída com sucesso: ${outFlow.type}');
    } catch (e) {
      print('Erro ao excluir saída: $e');
      throw e;
    }
  }

  Future<int> addPrints(List<PrintFile> _printFiles,
      {required Function(double) onProgress}) async {
    final totalPrintFiles = _printFiles.length;
    int itemsAdded = 0;
    final batch = FirebaseFirestore.instance.batch();
    final collection = FirebaseFirestore.instance.collection('printFiles');
    for (final _printFile in _printFiles) {
      final docRef = collection.doc();
      batch.set(docRef, _printFile.toMap());
      itemsAdded++;
      onProgress(itemsAdded / totalPrintFiles);
    }
    await batch.commit();
    return totalPrintFiles;
  }

  Future<List<PrintFile>> getPrints(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception("Arquivo não encontrado: $filePath");
    }
    final jsonString = await file.readAsString();
    final jsonData = json.decode(jsonString) as List;
    final List<PrintFile> _printFiles = jsonData
        .map((item) => PrintFile.fromMap(item, ''))
        .toList();
    return _printFiles;
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //Finisheds functions

  Future<void> saveFinished(Finished finished) async {
    await FirebaseFirestore.instance.collection('finisheds')
        .add(finished.toMap());
  }

  Future<void> updateFinished(Finished finished) async {
    await FirebaseFirestore.instance.collection('finisheds')
        .doc(finished.id)
        .update(finished.toMap());
  }

  Future<void> deleteFinished(Finished finished) async {
    await FirebaseFirestore.instance.collection('finisheds')
        .doc(finished.id)
        .delete();
  }

  Future<int> addFinisheds(List<Finished> _finisheds,
      {required Function(double) onProgress}) async {
    final totalFinisheds = _finisheds.length;
    int itemsAdded = 0;
    final batch = FirebaseFirestore.instance.batch();
    final collection = FirebaseFirestore.instance.collection('finisheds');
    for (final _finished in _finisheds) {
      final docRef = collection.doc();
      batch.set(docRef, _finished.toMap());
      itemsAdded++;
      onProgress(itemsAdded / totalFinisheds);
    }
    await batch.commit();
    return totalFinisheds;
  }

  Future<List<Finished>> getFinisheds(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception("Arquivo não encontrado: $filePath");
    }
    final jsonString = await file.readAsString();
    final jsonData = json.decode(jsonString) as List;
    final List<Finished> _finisheds = jsonData
        .map((item) => Finished.fromMap(item, ''))
        .toList();
    return _finisheds;
  }


  Future<int> addProducts(List<Product> _products,
      {required Function(double) onProgress}) async {
    final totalItems = _products.length;
    int itemsAdded = 0;
    final batch = FirebaseFirestore.instance.batch();
    final collection = FirebaseFirestore.instance.collection('products');
    for (final _product in _products) {
      final docRef = collection.doc();
      batch.set(docRef, _product.toMap());
      itemsAdded++;
      onProgress(itemsAdded / totalItems);
    }
    await batch.commit();
    return totalItems;
  }

  Future<List<Product>> getProducts(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception("Arquivo não encontrado: $filePath");
    }
    final jsonString = await file.readAsString();
    final jsonData = json.decode(jsonString) as List;
    final List<Product> _products = jsonData
        .map((item) => Product.fromMap(item, ''))
        .toList();
    return _products;
  }
}