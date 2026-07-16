import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/weather_model.dart';
import '../services/location_service.dart';
import '../services/mission/mission_service.dart';
import '../services/telemetry/telemetry_service.dart';
import '../services/weather/weather_service.dart';

/// Manages live weather state, auto-refresh and location switching.
///
/// Location priority:
/// 1. Mission-area override (set during manual/AI planning).
/// 2. Drone GPS when a mission is running.
/// 3. Device GPS (default).
class WeatherProvider extends ChangeNotifier {
  WeatherProvider() {
    _init();
  }

  // ── Dependencies ──────────────────────────────────────────────
  final _weatherService = WeatherService.instance;
  final _locationService = LocationService();

  // ── State ─────────────────────────────────────────────────────
  WeatherData? _weather;
  bool _loading = false;
  String? _error;

  /// Optional override coordinates set for mission-area planning.
  double? _missionLat;
  double? _missionLon;

  Timer? _refreshTimer;

  // ── Public getters ────────────────────────────────────────────
  WeatherData? get weather => _weather;
  bool get isLoading => _loading;
  String? get error => _error;

  // ── Lifecycle ─────────────────────────────────────────────────
  void _init() {
    refresh();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => refresh(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ── Public API ────────────────────────────────────────────────

  /// Override coordinates for the mission planning area.
  void setMissionLocation(double lat, double lon) {
    _missionLat = lat;
    _missionLon = lon;
    refresh();
  }

  /// Remove mission-area override and revert to device GPS.
  void clearMissionLocation() {
    _missionLat = null;
    _missionLon = null;
    refresh();
  }

  /// Trigger an immediate weather refresh.
  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final (double lat, double lon) = await _resolveLocation();
      final data = await _weatherService.fetchWeather(lat, lon);
      if (data != null) {
        _weather = data;
      } else {
        _error = 'Unable to fetch weather data.';
      }
    } catch (_) {
      _error = 'Weather unavailable.';
    }

    _loading = false;
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────────────

  Future<(double, double)> _resolveLocation() async {
    // 1. Mission-area override takes highest priority.
    if (_missionLat != null && _missionLon != null) {
      return (_missionLat!, _missionLon!);
    }

    // 2. When a mission is running, use drone GPS if available.
    final telemetry = TelemetryService.instance;
    if (MissionService.instance.isRunning &&
        (telemetry.latitude != 0 || telemetry.longitude != 0)) {
      return (telemetry.latitude, telemetry.longitude);
    }

    // 3. Default – device GPS.
    try {
      final position = await _locationService.getCurrentLocation();
      return (position.latitude, position.longitude);
    } catch (_) {
      return (0.0, 0.0);
    }
  }
}
