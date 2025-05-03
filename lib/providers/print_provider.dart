import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/print_data.dart';

class PrintProvider with ChangeNotifier {
  List<Print> _prints = [];
  List<Print> get prints => _prints;

  PrintProvider() {
    _listenToPrints();
  }

  void _listenToPrints() {
    FirebaseFirestore.instance
        .collection('prints')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      List<Print> newPrints = [];
      for (var doc in snapshot.docs) {
        newPrints.add(Print.fromMap(doc.data(), doc.id));
      }
      _prints = newPrints;
      notifyListeners();
    });
  }

  Future<void> refreshPrints() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('prints').get();
    _prints = snapshot.docs.map((doc) => Print.fromMap(doc.data(), doc.id)).toList();
    notifyListeners();
  }

  Future<void> savePrint(Print print) async {
    if (print.id == null) {
      // If the print doesn't have an ID, it's a new print
      DocumentReference docRef =
      await FirebaseFirestore.instance.collection('prints').add(print.toMap());
      print.id = docRef.id; // Update the print object with the newly generated ID
    } else {
      // If the print has an ID, it's an existing print that needs to be updated
      await FirebaseFirestore.instance
          .collection('prints')
          .doc(print.id)
          .update(print.toMap());
    }
    refreshPrints();
  }
}