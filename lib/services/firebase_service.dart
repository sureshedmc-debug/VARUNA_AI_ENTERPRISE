import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/drone_model.dart';
import 'location_service.dart';

class DroneService {
  final LocationService _locationService = LocationService();

  StreamSubscription<Position>? _gpsSubscription;

  final StreamController<DroneModel> _controller =
      StreamController<DroneModel>.broadcast();

  Stream<DroneModel> get droneStream => _controller.stream;

  double _battery = 100;

  void start() {
    _gpsSubscription =
        _locationService.getLiveLocation().listen((Position position) {
      _battery -= 0.02;

      if (_battery < 15) {
        _battery = 100;
      }

      _controller.add(
        DroneModel(
          connected: true,
          battery: _battery,
          satellites: 18,
          altitude: position.altitude,
          speed: position.speed,
          heading: position.heading,
          latitude: position.latitude,
          longitude: position.longitude,
          mode: "LOITER",
        ),
      );
    });
  }

  void stop() {
    _gpsSubscription?.cancel();
    _controller.close();
  }
}