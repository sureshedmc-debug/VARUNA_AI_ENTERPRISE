import '../controllers/connection_controller.dart';
import '../controllers/dashboard_controller.dart';

class ConnectionBinding {
  ConnectionBinding._();
  static final ConnectionBinding instance = ConnectionBinding._();

  Future<void> connectSystem() async {
    await ConnectionController.instance.connectAll();
    DashboardController.instance.refresh();
  }

  Future<void> disconnectSystem() async {
    await ConnectionController.instance.disconnectAll();
    DashboardController.instance.refresh();
  }
}

