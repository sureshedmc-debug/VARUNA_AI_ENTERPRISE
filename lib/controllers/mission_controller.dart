import 'package:flutter/foundation.dart';

import '../services/mission/mission_service.dart';
import '../core/services/logger_service.dart';

class MissionController extends ChangeNotifier {
  MissionController._();
  static final MissionController instance = MissionController._();

  final MissionService _mission = MissionService.instance;

  MissionService get mission => _mission;

  void start() {
    LoggerService.instance.mission('Mission Started');
    _mission.startMission();
    notifyListeners();
  }

  void pause() {
    LoggerService.instance.mission('Mission Paused');
    _mission.pauseMission();
    notifyListeners();
  }

  void resume() {
    LoggerService.instance.mission('Mission Resumed');
    _mission.resumeMission();
    notifyListeners();
  }

  void rtl() {
    LoggerService.instance.mission('RTL Initiated');
    _mission.rtl();
    notifyListeners();
  }

  void complete() {
    LoggerService.instance.mission('Mission Completed');
    _mission.completeMission();
    notifyListeners();
  }
}

