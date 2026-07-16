import 'package:flutter/foundation.dart';

import '../services/telemetry/telemetry_service.dart';
import '../services/mission/mission_service.dart';
import '../services/ai/ai_copilot_service.dart';
import '../services/network/connection_manager.dart';

class DashboardController extends ChangeNotifier {
  DashboardController._();
  static final DashboardController instance = DashboardController._();

  final telemetry = TelemetryService.instance;
  final mission = MissionService.instance;
  final ai = AICopilotService.instance;
  final connection = ConnectionManager.instance;

  void refresh() {
    ai.evaluate();
    notifyListeners();
  }

  bool get readyToFly =>
      telemetry.readyToFly &&
      connection.allSystemsReady;

  String get flightMode => telemetry.flightMode;
  double get battery => telemetry.battery;
  double get altitude => telemetry.altitude;
  double get heading => telemetry.heading;
}

 