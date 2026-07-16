import '../controllers/telemetry_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/ai_controller.dart';

class TelemetryBinding {
  TelemetryBinding._();
  static final TelemetryBinding instance = TelemetryBinding._();

  void onTelemetryUpdated() {
    DashboardController.instance.refresh();
    AIController.instance.refreshAdvice();
  }

  void reset() {
    TelemetryController.instance.reset();
    DashboardController.instance.refresh();
  }
}

 