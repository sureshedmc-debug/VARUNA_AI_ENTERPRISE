class TelemetryModel {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double heading;
  final double battery;
  final int satellites;
  final String flightMode;
  final bool armed;
  final DateTime timestamp;

  const TelemetryModel({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.battery,
    required this.satellites,
    required this.flightMode,
    required this.armed,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'battery': battery,
      'satellites': satellites,
      'flightMode': flightMode,
      'armed': armed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TelemetryModel.fromMap(Map<String, dynamic> map) {
    return TelemetryModel(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      altitude: (map['altitude'] as num?)?.toDouble() ?? 0,
      speed: (map['speed'] as num?)?.toDouble() ?? 0,
      heading: (map['heading'] as num?)?.toDouble() ?? 0,
      battery: (map['battery'] as num?)?.toDouble() ?? 100,
      satellites: map['satellites'] ?? 0,
      flightMode: map['flightMode'] ?? 'UNKNOWN',
      armed: map['armed'] ?? false,
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  TelemetryModel copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    double? heading,
    double? battery,
    int? satellites,
    String? flightMode,
    bool? armed,
    DateTime? timestamp,
  }) {
    return TelemetryModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      battery: battery ?? this.battery,
      satellites: satellites ?? this.satellites,
      flightMode: flightMode ?? this.flightMode,
      armed: armed ?? this.armed,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

