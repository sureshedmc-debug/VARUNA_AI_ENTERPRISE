import '../controllers/mission_controller.dart';
import '../controllers/map_controller.dart';
import '../controllers/report_controller.dart';

class MissionBinding {
  MissionBinding._();
  static final MissionBinding instance = MissionBinding._();

  Future<void> startMission() async {
    MissionController.instance.start();
  }

  Future<void> completeMission({
    required String missionName,
    required Duration duration,
    required double distance,
    required int detections,
  }) async {
    MissionController.instance.complete();

    await ReportController.instance.generate(
      missionName: missionName,
      duration: duration,
      distanceMeters: distance,
      detections: detections,
    );
  }

  void clearMission() {
    MapController.instance.clearMission();
  }
}

