import 'package:flutter/foundation.dart';

import '../services/network/connection_manager.dart';
import '../services/raspberry_pi/raspberry_pi_service.dart';
import '../services/pixhawk/pixhawk_service.dart';

class ConnectionController extends ChangeNotifier {
  ConnectionController._();

  static final ConnectionController instance =
      ConnectionController._();

  final ConnectionManager manager = ConnectionManager.instance;

  Future<void> connectAll() async {
    await RaspberryPiService.instance.connect();
    await PixhawkService.instance.connect();
    notifyListeners();
  }

  Future<void> disconnectAll() async {
    await RaspberryPiService.instance.disconnect();
    await PixhawkService.instance.disconnect();
    notifyListeners();
  }

  bool get allConnected => manager.allSystemsReady;
}

