/// Flat representation of a [TelemetrySnapshot] as broadcast by the backend
/// WebSocket at 10 Hz and available via the REST endpoint.
///
/// Field names follow the backend Pydantic schema defined in
/// `backend/app/models/telemetry.py`.
class DroneModel {
  // ── WebSocket layer ───────────────────────────────────────────────────────
  /// True when the WebSocket connection to the Raspberry Pi is active.
  final bool wsConnected;

  // ── MAVLink / Pixhawk ─────────────────────────────────────────────────────
  /// True when the Pixhawk has an active MAVLink session.
  final bool connected;

  /// True when the vehicle is armed.
  final bool armed;

  /// ArduPilot flight mode string (e.g. "LOITER", "AUTO", "RTL").
  final String mode;

  /// MAV_STATE enum value.
  final int systemStatus;

  // ── Attitude ─────────────────────────────────────────────────────────────
  /// Compass heading in degrees 0-359.
  final double heading;

  /// Roll angle in radians.
  final double roll;

  /// Pitch angle in radians.
  final double pitch;

  // ── Position ─────────────────────────────────────────────────────────────
  final double latitude;
  final double longitude;

  /// Altitude above home position in metres (relative).
  final double altitude;

  /// Altitude above mean sea level in metres.
  final double altitudeMsl;

  // ── Velocity ─────────────────────────────────────────────────────────────
  /// Ground speed in m/s.
  final double speed;

  /// Indicated airspeed in m/s.
  final double airspeed;

  // ── GPS ──────────────────────────────────────────────────────────────────
  /// Number of visible satellites.
  final int satellites;

  /// GPS fix type: 0=no GPS, 3=3D fix, 6=RTK.
  final int gpsFixType;

  /// Horizontal dilution of precision.
  final double hdop;

  // ── Battery ──────────────────────────────────────────────────────────────
  /// Remaining battery percentage 0-100 (-1 if unknown).
  final double battery;

  /// Battery voltage in volts.
  final double batteryVoltage;

  /// Battery current draw in amps (-1 if unknown).
  final double batteryCurrent;

  // ── Metadata ─────────────────────────────────────────────────────────────
  /// Unix timestamp of this snapshot.
  final DateTime timestamp;

  const DroneModel({
    required this.wsConnected,
    required this.connected,
    required this.armed,
    required this.mode,
    required this.systemStatus,
    required this.heading,
    required this.roll,
    required this.pitch,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.altitudeMsl,
    required this.speed,
    required this.airspeed,
    required this.satellites,
    required this.gpsFixType,
    required this.hdop,
    required this.battery,
    required this.batteryVoltage,
    required this.batteryCurrent,
    required this.timestamp,
  });

  // ── Factories ─────────────────────────────────────────────────────────────

  /// Disconnected initial state (shown before the first WebSocket frame).
  factory DroneModel.initial() {
    return DroneModel(
      wsConnected: false,
      connected: false,
      armed: false,
      mode: 'DISCONNECTED',
      systemStatus: 0,
      heading: 0,
      roll: 0,
      pitch: 0,
      latitude: 0,
      longitude: 0,
      altitude: 0,
      altitudeMsl: 0,
      speed: 0,
      airspeed: 0,
      satellites: 0,
      gpsFixType: 0,
      hdop: 99.99,
      battery: 0,
      batteryVoltage: 0,
      batteryCurrent: 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Parse a [TelemetrySnapshot] JSON frame from the backend WebSocket.
  factory DroneModel.fromJson(Map<String, dynamic> json) {
    final pos = (json['position'] as Map<String, dynamic>?) ?? {};
    final vel = (json['velocity'] as Map<String, dynamic>?) ?? {};
    final gps = (json['gps'] as Map<String, dynamic>?) ?? {};
    final bat = (json['battery'] as Map<String, dynamic>?) ?? {};
    final att = (json['attitude'] as Map<String, dynamic>?) ?? {};

    final tsRaw = (json['timestamp'] as num?)?.toDouble() ?? 0.0;

    return DroneModel(
      wsConnected: true,
      connected: json['connected'] as bool? ?? false,
      armed: json['armed'] as bool? ?? false,
      mode: (json['mode'] as String?) ?? 'UNKNOWN',
      systemStatus: (json['system_status'] as num?)?.toInt() ?? 0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0,
      roll: (att['roll'] as num?)?.toDouble() ?? 0,
      pitch: (att['pitch'] as num?)?.toDouble() ?? 0,
      latitude: (pos['lat'] as num?)?.toDouble() ?? 0,
      longitude: (pos['lon'] as num?)?.toDouble() ?? 0,
      altitude: (pos['alt_rel'] as num?)?.toDouble() ?? 0,
      altitudeMsl: (pos['alt_msl'] as num?)?.toDouble() ?? 0,
      speed: (vel['groundspeed'] as num?)?.toDouble() ?? 0,
      airspeed: (vel['airspeed'] as num?)?.toDouble() ?? 0,
      satellites: (gps['satellites_visible'] as num?)?.toInt() ?? 0,
      gpsFixType: (gps['fix_type'] as num?)?.toInt() ?? 0,
      hdop: (gps['hdop'] as num?)?.toDouble() ?? 99.99,
      battery: ((bat['remaining'] as num?)?.toDouble() ?? 0).clamp(0, 100),
      batteryVoltage: (bat['voltage'] as num?)?.toDouble() ?? 0,
      batteryCurrent: (bat['current'] as num?)?.toDouble() ?? 0,
      timestamp: tsRaw > 0
          ? DateTime.fromMillisecondsSinceEpoch((tsRaw * 1000).toInt())
          : DateTime.now(),
    );
  }

  // ── Derived helpers ───────────────────────────────────────────────────────

  /// True when GPS fix type ≥ 3D (fix_type 3 or higher).
  bool get gpsReady => gpsFixType >= 3;

  /// Battery percentage clamped to [0, 100].
  double get batteryPercent => battery.clamp(0, 100);

  // ── copyWith ──────────────────────────────────────────────────────────────

  DroneModel copyWith({
    bool? wsConnected,
    bool? connected,
    bool? armed,
    String? mode,
    int? systemStatus,
    double? heading,
    double? roll,
    double? pitch,
    double? latitude,
    double? longitude,
    double? altitude,
    double? altitudeMsl,
    double? speed,
    double? airspeed,
    int? satellites,
    int? gpsFixType,
    double? hdop,
    double? battery,
    double? batteryVoltage,
    double? batteryCurrent,
    DateTime? timestamp,
  }) {
    return DroneModel(
      wsConnected: wsConnected ?? this.wsConnected,
      connected: connected ?? this.connected,
      armed: armed ?? this.armed,
      mode: mode ?? this.mode,
      systemStatus: systemStatus ?? this.systemStatus,
      heading: heading ?? this.heading,
      roll: roll ?? this.roll,
      pitch: pitch ?? this.pitch,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      altitudeMsl: altitudeMsl ?? this.altitudeMsl,
      speed: speed ?? this.speed,
      airspeed: airspeed ?? this.airspeed,
      satellites: satellites ?? this.satellites,
      gpsFixType: gpsFixType ?? this.gpsFixType,
      hdop: hdop ?? this.hdop,
      battery: battery ?? this.battery,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      batteryCurrent: batteryCurrent ?? this.batteryCurrent,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
