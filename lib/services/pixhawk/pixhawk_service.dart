import 'package:flutter/foundation.dart';

class PixhawkService extends ChangeNotifier {
  PixhawkService._();
  static final PixhawkService instance = PixhawkService._();

  bool _connected = false;

  bool get isConnected => _connected;

  Future<void> connect() async {
    _connected = true;
    notifyListeners();
  }

  Future<void> disconnect() async {
    _connected = false;
    notifyListeners();
  }

  Future<void> arm() async {}

  Future<void> disarm() async {}

  Future<void> takeoff(double altitude) async {}

  Future<void> rtl() async {}

  Future<void> land() async {}
}

