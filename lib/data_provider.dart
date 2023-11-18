import 'package:flutter/material.dart';

class BusNumberProvider extends ChangeNotifier {
  late String _busNumber;

  String get busNumber => _busNumber;

  void setBusNumber(String busNumber) {
    _busNumber = busNumber;
    notifyListeners();
  }
}
