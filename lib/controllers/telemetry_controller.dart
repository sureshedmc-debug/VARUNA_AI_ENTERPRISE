import 'package:flutter/foundation.dart';

import '../services/telemetry/telemetry_service.dart';
import '../core/services/logger_service.dart';

class TelemetryController extends ChangeNotifier {
  TelemetryController._();
  static final TelemetryController instance = TelemetryController._();

  final TelemetryService telemetry = TelemetryService.instance;

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
    telemetry.update(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      speed: speed,
      heading: heading,
      battery: battery,
      satellites: satellites,
      flightMode: flightMode,
      armed: armed,
    );

    LoggerService.instance.telemetry(
      'Alt:${altitude.toStringAsFixed(1)}m Bat:${battery.toStringAsFixed(0)}%',
    );

    notifyListeners();
  }

  void reset() {
    telemetry.reset();
    notifyListeners();
  }
}
