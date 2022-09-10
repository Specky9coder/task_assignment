import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  bool _isReload = false;

  set isReload(bool value) {
    _isReload = value;
    notifyListeners();
  }

  bool get isReload => _isReload;

  List<Map<String, dynamic>> _products = [];

  List<Map<String, dynamic>> get products => _products;

  set products(List<Map<String, dynamic>> value) {
    _products = value;
    notifyListeners();
  }
}
