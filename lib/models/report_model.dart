class ReportModel {
  final int? id;
  final String missionName;
  final DateTime createdAt;
  final double distanceMeters;
  final Duration duration;
  final int detections;
  final String reportPath;

  const ReportModel({
    this.id,
    required this.missionName,
    required this.createdAt,
    required this.distanceMeters,
    required this.duration,
    required this.detections,
    required this.reportPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'missionName': missionName,
      'createdAt': createdAt.toIso8601String(),
      'distanceMeters': distanceMeters,
      'durationSeconds': duration.inSeconds,
      'detections': detections,
      'reportPath': reportPath,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] as int?,
      missionName: map['missionName'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      distanceMeters: (map['distanceMeters'] as num).toDouble(),
      duration: Duration(seconds: map['durationSeconds'] ?? 0),
      detections: map['detections'] ?? 0,
      reportPath: map['reportPath'] ?? '',
    );
  }

  ReportModel copyWith({
    int? id,
    String? missionName,
    DateTime? createdAt,
    double? distanceMeters,
    Duration? duration,
    int? detections,
    String? reportPath,
  }) {
    return ReportModel(
      id: id ?? this.id,
      missionName: missionName ?? this.missionName,
      createdAt: createdAt ?? this.createdAt,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      duration: duration ?? this.duration,
      detections: detections ?? this.detections,
      reportPath: reportPath ?? this.reportPath,
    );
  }
}

