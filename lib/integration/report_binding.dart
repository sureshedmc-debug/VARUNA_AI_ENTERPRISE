import '../controllers/report_controller.dart';
import '../controllers/mission_controller.dart';

class ReportBinding {
  ReportBinding._();
  static final ReportBinding instance = ReportBinding._();

  Future<String> finishMission({
    required String missionName,
    required Duration duration,
    required double distanceMeters,
    required int detections,
  }) async {
    MissionController.instance.complete();

    return await ReportController.instance.generate(
      missionName: missionName,
      duration: duration,
      distanceMeters: distanceMeters,
      detections: detections,
    );
  }
}

