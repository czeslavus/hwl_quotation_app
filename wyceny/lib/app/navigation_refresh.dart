import 'package:flutter/foundation.dart';

class NavigationRefresh extends ChangeNotifier {
  int _quotationsVersion = 0;
  int _ordersVersion = 0;

  int get quotationsVersion => _quotationsVersion;
  int get ordersVersion => _ordersVersion;

  void refreshQuotations() {
    _quotationsVersion++;
    notifyListeners();
  }

  void refreshOrders() {
    _ordersVersion++;
    notifyListeners();
  }
}
