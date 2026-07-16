import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/drone_model.dart';
import 'location_service.dart';

class DroneService {
  final LocationService _locationService = LocationService();

  final StreamController<DroneModel> _controller =
      StreamController<DroneModel>.broadcast();

  Stream<DroneModel> get droneStream => _controller.stream;

  StreamSubscription<Position>? _positionSubscription;

  double _battery = 100;

  void start() {
    _positionSubscription =
        _locationService.getLiveLocation().listen((position) {
      _battery -= 0.02;

      if (_battery <= 0) {
        _battery = 100;
      }

      final drone = DroneModel(
        connected: true,
        battery: _battery,
        satellites: 18,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        latitude: position.latitude,
        longitude: position.longitude,
        mode: "LOITER",
      );

      _controller.add(drone);
    });
  }

  void stop() {
    _positionSubscription?.cancel();
  }

  void dispose() {
    _positionSubscription?.cancel();
    _controller.close();
  }
}