import 'package:flutter/foundation.dart';

class TelemetryService extends ChangeNotifier {
  TelemetryService._();
  static final TelemetryService instance = TelemetryService._();

  double latitude = 0;
  double longitude = 0;
  double altitude = 0;
  double speed = 0;
  double heading = 0;
  double battery = 100;
  int satellites = 0;
  String flightMode = 'UNKNOWN';
  bool armed = false;

  bool get readyToFly => battery > 20 && satellites >= 8;
  bool get gpsReady => satellites >= 8;

  void update({
    required double latitude,
    required double longitude,
    required double altitude,
    required double speed,
    required double heading,
    required double battery,
    required int satellites,
    required String flightMode,
    bool armed = false,
  }) {
    this.latitude = latitude;
    this.longitude = longitude;
    this.altitude = altitude;
    this.speed = speed;
    this.heading = heading;
    this.battery = battery;
    this.satellites = satellites;
    this.flightMode = flightMode;
    this.armed = armed;
    notifyListeners();
  }

  void reset() {
    latitude = longitude = altitude = speed = heading = 0;
    battery = 100;
    satellites = 0;
    flightMode = 'UNKNOWN';
    armed = false;
    notifyListeners();
  }
}

 