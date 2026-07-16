class GeofenceModel {
  final int? id;
  final String name;
  final double centerLatitude;
  final double centerLongitude;
  final double radiusMeters;
  final bool enabled;

  const GeofenceModel({
    this.id,
    required this.name,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusMeters,
    this.enabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'centerLatitude': centerLatitude,
      'centerLongitude': centerLongitude,
      'radiusMeters': radiusMeters,
      'enabled': enabled,
    };
  }

  factory GeofenceModel.fromMap(Map<String, dynamic> map) {
    return GeofenceModel(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      centerLatitude: (map['centerLatitude'] as num?)?.toDouble() ?? 0.0,
      centerLongitude: (map['centerLongitude'] as num?)?.toDouble() ?? 0.0,
      radiusMeters: (map['radiusMeters'] as num?)?.toDouble() ?? 0.0,
      enabled: map['enabled'] ?? true,
    );
  }

  GeofenceModel copyWith({
    int? id,
    String? name,
    double? centerLatitude,
    double? centerLongitude,
    double? radiusMeters,
    bool? enabled,
  }) {
    return GeofenceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      centerLatitude: centerLatitude ?? this.centerLatitude,
      centerLongitude: centerLongitude ?? this.centerLongitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      enabled: enabled ?? this.enabled,
    );
  }

  bool contains(double latitude, double longitude) {
    final dx = latitude - centerLatitude;
    final dy = longitude - centerLongitude;
    const metersPerDegree = 111320.0;
    final distance =
        ((dx * metersPerDegree) * (dx * metersPerDegree) +
         (dy * metersPerDegree) * (dy * metersPerDegree));
    return distance <= radiusMeters * radiusMeters;
  }
}

