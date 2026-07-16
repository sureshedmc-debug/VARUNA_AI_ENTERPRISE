import 'dart:async';

import 'package:flutter/material.dart';

import '../models/drone_model.dart';
import '../services/drone_service.dart';

class DroneProvider extends ChangeNotifier {
  final DroneService _service = DroneService();

  DroneModel _drone = DroneModel.demo();

  DroneModel get drone => _drone;

  StreamSubscription? _subscription;

  void start() {
    _service.start();

    _subscription = _service.droneStream.listen((event) {
      _drone = event;
      notifyListeners();
    });
  }

  void stop() {
    _subscription?.cancel();
    _service.stop();
  }
}