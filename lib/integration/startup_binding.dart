import '../core/services/app_initializer.dart';
import '../controllers/connection_controller.dart';
import '../controllers/dashboard_controller.dart';

class StartupBinding {
  StartupBinding._();
  static final StartupBinding instance = StartupBinding._();

  Future<void> initializeApp() async {
    await AppInitializer.instance.initialize();
    DashboardController.instance.refresh();
  }

  Future<void> connectOnStartup() async {
    await ConnectionController.instance.connectAll();
    DashboardController.instance.refresh();
  }
}

 