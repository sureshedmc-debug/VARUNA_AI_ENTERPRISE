import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

class RaspberryPiService extends ChangeNotifier {
  RaspberryPiService._();
  static final RaspberryPiService instance = RaspberryPiService._();

  Socket? _socket;
  bool _connected = false;

  bool get isConnected => _connected;

  Future<bool> connect({
    String host = '192.168.4.1',
    int port = 8000,
  }) async {
    try {
      _socket = await Socket.connect(host, port);
      _connected = true;
      notifyListeners();
      return true;
    } catch (_) {
      _connected = false;
      notifyListeners();
      return false;
    }
  }

  void send(String command) {
    _socket?.writeln(command);
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    _connected = false;
    notifyListeners();
  }
}

 