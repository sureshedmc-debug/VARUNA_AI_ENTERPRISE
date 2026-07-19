import 'dart:async';

import 'package:flutter/material.dart';

import '../models/drone_model.dart';
import '../services/drone_service.dart';
import '../services/network/connection_manager.dart';
import '../services/network/websocket_service.dart';
import '../services/telemetry/telemetry_service.dart';
import '../services/video/video_stream_service.dart';

/// The single source of truth for all drone telemetry.
///
/// Initialised once in [main.dart] via [ChangeNotifierProvider].  Every
/// widget that needs live drone data should [watch] or [Consumer]-listen
/// to this provider instead of reading singleton services directly.
class DroneProvider extends ChangeNotifier {
  final DroneService _service = DroneService();

  DroneModel _drone = DroneModel.initial();
  DroneModel get drone => _drone;

  StreamSubscription<DroneModel>? _droneSubscription;

  // ── WebSocket status ───────────────────────────────────────────────────────

  WsStatus get wsStatus => WebSocketService.instance.status;
  bool get isWsConnected => WebSocketService.instance.isConnected;

  // ── Convenience telemetry getters ──────────────────────────────────────────

  bool get isConnected => _drone.wsConnected && _drone.connected;
  bool get isArmed => _drone.armed;
  String get flightMode => _drone.mode;

  double get battery => _drone.batteryPercent;
  double get batteryVoltage => _drone.batteryVoltage;
  double get batteryCurrent => _drone.batteryCurrent;

  double get altitude => _drone.altitude;
  double get altitudeMsl => _drone.altitudeMsl;
  double get speed => _drone.speed;
  double get airspeed => _drone.airspeed;
  double get heading => _drone.heading;

  double get latitude => _drone.latitude;
  double get longitude => _drone.longitude;

  int get satellites => _drone.satellites;
  int get gpsFixType => _drone.gpsFixType;
  bool get gpsReady => _drone.gpsReady;
  double get hdop => _drone.hdop;

  double get roll => _drone.roll;
  double get pitch => _drone.pitch;

  DateTime get lastUpdate => _drone.timestamp;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  void start() {
    _service.start();

    // Receive live telemetry frames from the backend.
    _droneSubscription = _service.droneStream.listen(_onTelemetry);

    // React to WebSocket status changes (connected / disconnected).
    WebSocketService.instance.addListener(_onWsStatusChanged);

    // Start MJPEG video stream.
    VideoStreamService.instance.start();
  }

  void stop() {
    _droneSubscription?.cancel();
    _droneSubscription = null;
    WebSocketService.instance.removeListener(_onWsStatusChanged);
    _service.stop();
    VideoStreamService.instance.stop();
  }

  void _onTelemetry(DroneModel model) {
    _drone = model;

    // Keep the legacy TelemetryService singleton in sync so widgets that
    // still AnimatedBuilder-listen to it also receive live data.
    TelemetryService.instance.update(
      latitude: model.latitude,
      longitude: model.longitude,
      altitude: model.altitude,
      speed: model.speed,
      heading: model.heading,
      battery: model.batteryPercent,
      satellites: model.satellites,
      flightMode: model.mode,
      armed: model.armed,
    );

    // Keep ConnectionManager in sync.
    ConnectionManager.instance
        .updateRaspberryPi(model.wsConnected
            ? ConnectionStatus.connected
            : ConnectionStatus.disconnected);
    ConnectionManager.instance
        .updatePixhawk(model.connected
            ? ConnectionStatus.connected
            : ConnectionStatus.disconnected);

    notifyListeners();
  }

  void _onWsStatusChanged() {
    if (!WebSocketService.instance.isConnected) {
      // Mark drone as disconnected so the UI reflects the actual state.
      _drone = DroneModel.initial();
      TelemetryService.instance.reset();
      ConnectionManager.instance
          .updateRaspberryPi(ConnectionStatus.disconnected);
      ConnectionManager.instance
          .updatePixhawk(ConnectionStatus.disconnected);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
