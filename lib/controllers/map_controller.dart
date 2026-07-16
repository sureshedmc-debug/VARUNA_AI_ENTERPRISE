import 'package:flutter/foundation.dart';

import '../services/telemetry/telemetry_service.dart';
import '../models/waypoint_model.dart';
import '../models/geofence_model.dart';

class MapController extends ChangeNotifier {
  MapController._();
  static final MapController instance = MapController._();

  final telemetry = TelemetryService.instance;

  final List<WaypointModel> _waypoints = [];
  final List<GeofenceModel> _geofences = [];

  List<WaypointModel> get waypoints => List.unmodifiable(_waypoints);
  List<GeofenceModel> get geofences => List.unmodifiable(_geofences);

  void addWaypoint(WaypointModel waypoint) {
    _waypoints.add(waypoint);
    notifyListeners();
  }

  void addGeofence(GeofenceModel geofence) {
    _geofences.add(geofence);
    notifyListeners();
  }

  void clearMission() {
    _waypoints.clear();
    notifyListeners();
  }
}

 