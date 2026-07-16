import '../controllers/dashboard_controller.dart';

import '../controllers/ai_controller.dart';

class DashboardBinding {
  DashboardBinding._();
  static final DashboardBinding instance = DashboardBinding._();

  void initialize() {
    DashboardController.instance.refresh();
    AIController.instance.refreshAdvice();
  }

  void refreshDashboard() {
    DashboardController.instance.refresh();
  }
}

 