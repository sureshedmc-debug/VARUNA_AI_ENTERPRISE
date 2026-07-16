class MissionStatisticsModel {
  final int totalDetections;
  final int plasticCount;
  final int garbageCount;
  final int bottleCount;
  final int canCount;
  final double areaCoveredSqMeters;
  final double flightDistanceMeters;
  final Duration flightDuration;

  const MissionStatisticsModel({
    required this.totalDetections,
    required this.plasticCount,
    required this.garbageCount,
    required this.bottleCount,
    required this.canCount,
    required this.areaCoveredSqMeters,
    required this.flightDistanceMeters,
    required this.flightDuration,
  });

  factory MissionStatisticsModel.empty() {
    return const MissionStatisticsModel(
      totalDetections: 0,
      plasticCount: 0,
      garbageCount: 0,
      bottleCount: 0,
      canCount: 0,
      areaCoveredSqMeters: 0,
      flightDistanceMeters: 0,
      flightDuration: Duration.zero,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalDetections': totalDetections,
      'plasticCount': plasticCount,
      'garbageCount': garbageCount,
      'bottleCount': bottleCount,
      'canCount': canCount,
      'areaCoveredSqMeters': areaCoveredSqMeters,
      'flightDistanceMeters': flightDistanceMeters,
      'flightDurationSeconds': flightDuration.inSeconds,
    };
  }

  factory MissionStatisticsModel.fromMap(Map<String, dynamic> map) {
    return MissionStatisticsModel(
      totalDetections: map['totalDetections'] ?? 0,
      plasticCount: map['plasticCount'] ?? 0,
      garbageCount: map['garbageCount'] ?? 0,
      bottleCount: map['bottleCount'] ?? 0,
      canCount: map['canCount'] ?? 0,
      areaCoveredSqMeters:
          (map['areaCoveredSqMeters'] as num?)?.toDouble() ?? 0,
      flightDistanceMeters:
          (map['flightDistanceMeters'] as num?)?.toDouble() ?? 0,
      flightDuration: Duration(
        seconds: map['flightDurationSeconds'] ?? 0,
      ),
    );
  }

  MissionStatisticsModel copyWith({
    int? totalDetections,
    int? plasticCount,
    int? garbageCount,
    int? bottleCount,
    int? canCount,
    double? areaCoveredSqMeters,
    double? flightDistanceMeters,
    Duration? flightDuration,
  }) {
    return MissionStatisticsModel(
      totalDetections: totalDetections ?? this.totalDetections,
      plasticCount: plasticCount ?? this.plasticCount,
      garbageCount: garbageCount ?? this.garbageCount,
      bottleCount: bottleCount ?? this.bottleCount,
      canCount: canCount ?? this.canCount,
      areaCoveredSqMeters:
          areaCoveredSqMeters ?? this.areaCoveredSqMeters,
      flightDistanceMeters:
          flightDistanceMeters ?? this.flightDistanceMeters,
      flightDuration: flightDuration ?? this.flightDuration,
    );
  }
}

