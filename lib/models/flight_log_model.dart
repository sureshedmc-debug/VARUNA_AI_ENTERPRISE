class FlightLogModel {
  final int? id;
  final String missionName;
  final DateTime startTime;
  final DateTime endTime;
  final double maxAltitude;
  final double totalDistance;
  final double averageSpeed;
  final double maxSpeed;
  final double batteryStart;
  final double batteryEnd;
  final int detections;
  final bool completedSuccessfully;

  const FlightLogModel({
    this.id,
    required this.missionName,
    required this.startTime,
    required this.endTime,
    required this.maxAltitude,
    required this.totalDistance,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.batteryStart,
    required this.batteryEnd,
    required this.detections,
    required this.completedSuccessfully,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'missionName': missionName,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'maxAltitude': maxAltitude,
    'totalDistance': totalDistance,
    'averageSpeed': averageSpeed,
    'maxSpeed': maxSpeed,
    'batteryStart': batteryStart,
    'batteryEnd': batteryEnd,
    'detections': detections,
    'completedSuccessfully': completedSuccessfully,
  };

  factory FlightLogModel.fromMap(Map<String, dynamic> map) {
    return FlightLogModel(
      id: map['id'] as int?,
      missionName: map['missionName'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      maxAltitude: (map['maxAltitude'] as num?)?.toDouble() ?? 0,
      totalDistance: (map['totalDistance'] as num?)?.toDouble() ?? 0,
      averageSpeed: (map['averageSpeed'] as num?)?.toDouble() ?? 0,
      maxSpeed: (map['maxSpeed'] as num?)?.toDouble() ?? 0,
      batteryStart: (map['batteryStart'] as num?)?.toDouble() ?? 100,
      batteryEnd: (map['batteryEnd'] as num?)?.toDouble() ?? 100,
      detections: map['detections'] ?? 0,
      completedSuccessfully: map['completedSuccessfully'] ?? false,
    );
  }

  FlightLogModel copyWith({
    int? id,
    String? missionName,
    DateTime? startTime,
    DateTime? endTime,
    double? maxAltitude,
    double? totalDistance,
    double? averageSpeed,
    double? maxSpeed,
    double? batteryStart,
    double? batteryEnd,
    int? detections,
    bool? completedSuccessfully,
  }) {
    return FlightLogModel(
      id: id ?? this.id,
      missionName: missionName ?? this.missionName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxAltitude: maxAltitude ?? this.maxAltitude,
      totalDistance: totalDistance ?? this.totalDistance,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      batteryStart: batteryStart ?? this.batteryStart,
      batteryEnd: batteryEnd ?? this.batteryEnd,
      detections: detections ?? this.detections,
      completedSuccessfully: completedSuccessfully ?? this.completedSuccessfully,
    );
  }
}

