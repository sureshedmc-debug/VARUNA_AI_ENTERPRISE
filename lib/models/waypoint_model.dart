class WaypointModel {
  final int? id;
  final int sequence;
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final bool isHome;
  final bool isRtlPoint;

  const WaypointModel({
    this.id,
    required this.sequence,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    this.speed = 5.0,
    this.isHome = false,
    this.isRtlPoint = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sequence': sequence,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'isHome': isHome,
      'isRtlPoint': isRtlPoint,
    };
  }

  factory WaypointModel.fromMap(Map<String, dynamic> map) {
    return WaypointModel(
      id: map['id'] as int?,
      sequence: map['sequence'] ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      altitude: (map['altitude'] as num?)?.toDouble() ?? 0,
      speed: (map['speed'] as num?)?.toDouble() ?? 5,
      isHome: map['isHome'] ?? false,
      isRtlPoint: map['isRtlPoint'] ?? false,
    );
  }

  WaypointModel copyWith({
    int? id,
    int? sequence,
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    bool? isHome,
    bool? isRtlPoint,
  }) {
    return WaypointModel(
      id: id ?? this.id,
      sequence: sequence ?? this.sequence,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      isHome: isHome ?? this.isHome,
      isRtlPoint: isRtlPoint ?? this.isRtlPoint,
    );
  }
}

