class GPSModel {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double accuracy;
  final double heading;
  final DateTime timestamp;

  const GPSModel({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.accuracy,
    required this.heading,
    required this.timestamp,
  });

  factory GPSModel.empty() {
    return GPSModel(
      latitude: 0,
      longitude: 0,
      altitude: 0,
      speed: 0,
      accuracy: 0,
      heading: 0,
      timestamp: DateTime.now(),
    );
  }

  GPSModel copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    double? accuracy,
    double? heading,
    DateTime? timestamp,
  }) {
    return GPSModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}