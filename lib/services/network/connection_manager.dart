
import 'package:flutter/foundation.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
}

class ConnectionManager extends ChangeNotifier {
  ConnectionManager._();
  static final ConnectionManager instance = ConnectionManager._();

  ConnectionStatus raspberryPi = ConnectionStatus.disconnected;
  ConnectionStatus pixhawk = ConnectionStatus.disconnected;

  bool get allSystemsReady =>
      raspberryPi == ConnectionStatus.connected &&
      pixhawk == ConnectionStatus.connected;
  bool get isPixhawkConnected =>
    pixhawk == ConnectionStatus.connected;
  bool get isTelemetryConnected =>
    allSystemsReady;

  void updateRaspberryPi(ConnectionStatus status) {
    raspberryPi = status;
    notifyListeners();
  }

  void updatePixhawk(ConnectionStatus status) {
    pixhawk = status;
    notifyListeners();
  }
}

