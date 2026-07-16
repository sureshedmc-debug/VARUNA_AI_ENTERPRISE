import 'package:flutter/foundation.dart';

enum MissionState {
  idle,
  created,
  running,
  paused,
  rtl,
  completed,
}

enum MissionType {
  manual,
  aiGenerated,
  survey,
  waypoint,
}

class MissionService extends ChangeNotifier {
  MissionService._();
  static final MissionService instance = MissionService._();

  String _missionName = '';
  MissionState _state = MissionState.idle;
  MissionType _type = MissionType.manual;

  int _waypointCount = 0;
  double _missionDistance = 0;
  Duration _missionDuration = Duration.zero;

  bool get isRunning => _state == MissionState.running;
  bool get isPaused => _state == MissionState.paused;

  String get missionName => _missionName;
  MissionState get state => _state;
  MissionType get type => _type;
  int get waypointCount => _waypointCount;
  double get missionDistance => _missionDistance;
  Duration get missionDuration => _missionDuration;

  void createMission({
    required String name,
    required MissionType type,
    int waypointCount = 0,
  }) {
    _missionName = name;
    _type = type;
    _waypointCount = waypointCount;
    _state = MissionState.created;
    notifyListeners();
  }

  void startMission() {
    if (_state == MissionState.created ||
        _state == MissionState.paused) {
      _state = MissionState.running;
      notifyListeners();
    }
  }

  void pauseMission() {
    if (_state == MissionState.running) {
      _state = MissionState.paused;
      notifyListeners();
    }
  }

  void resumeMission() {
    if (_state == MissionState.paused) {
      _state = MissionState.running;
      notifyListeners();
    }
  }

  void updateStatistics({
    double? distance,
    Duration? duration,
    int? waypointCount,
  }) {
    if (distance != null) _missionDistance = distance;
    if (duration != null) _missionDuration = duration;
    if (waypointCount != null) _waypointCount = waypointCount;
    notifyListeners();
  }

  void rtl() {
    _state = MissionState.rtl;
    notifyListeners();
  }

  void completeMission() {
    _state = MissionState.completed;
    notifyListeners();
  }

  void resetMission() {
    _missionName = '';
    _type = MissionType.manual;
    _state = MissionState.idle;
    _waypointCount = 0;
    _missionDistance = 0;
    _missionDuration = Duration.zero;
    notifyListeners();
  }
}

