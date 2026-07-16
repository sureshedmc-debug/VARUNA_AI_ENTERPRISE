import 'dart:typed_data';

import '../controllers/ai_controller.dart';

import '../controllers/dashboard_controller.dart';

class AIBinding {
  AIBinding._();
  static final AIBinding instance = AIBinding._();

  Future<void> processFrame(List<int> frameBytes) async {
    await AIController.instance.detectFrame(
      Uint8List.fromList(frameBytes),
    );
    DashboardController.instance.refresh();
  }

  Future<void> refreshAI() async {
    await AIController.instance.refreshAdvice();
  }
}

 