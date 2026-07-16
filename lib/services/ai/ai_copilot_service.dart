import 'package:flutter/foundation.dart';

import '../mission/mission_service.dart';
import '../telemetry/telemetry_service.dart';

enum AIAdviceLevel {
  info,
  caution,
  warning,
}

class AIAdvice {
  final AIAdviceLevel level;
  final String message;

  const AIAdvice({
    required this.level,
    required this.message,
  });
}

class AICopilotService extends ChangeNotifier {
  AICopilotService._();

  static final AICopilotService instance = AICopilotService._();

  AIAdvice _currentAdvice = const AIAdvice(
    level: AIAdviceLevel.info,
    message: "System Ready",
  );

  AIAdvice get currentAdvice => _currentAdvice;

  Future<void> initialize() async {}

  void evaluate() {
    final telemetry = TelemetryService.instance;
    final mission = MissionService.instance;

    if (telemetry.battery < 20) {
      _currentAdvice = const AIAdvice(
        level: AIAdviceLevel.warning,
        message: "Battery critically low. Return to Launch recommended.",
      );
    } else if (!telemetry.gpsReady) {
      _currentAdvice = const AIAdvice(
        level: AIAdviceLevel.caution,
        message: "GPS lock insufficient for safe autonomous flight.",
      );
    } else if (mission.state == MissionState.running) {
      _currentAdvice = const AIAdvice(
        level: AIAdviceLevel.info,
        message: "Mission progressing normally.",
      );
    } else {
      _currentAdvice = const AIAdvice(
        level: AIAdviceLevel.info,
        message: "Drone ready for mission planning.",
      );
    }

    notifyListeners();
  }

  void setAdvice(AIAdvice advice) {
    _currentAdvice = advice;
    notifyListeners();
  }
}

