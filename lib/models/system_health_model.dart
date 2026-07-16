enum SystemHealth {
  healthy,
  warning,
  critical,
}

class SystemHealthModel {
  final SystemHealth overall;
  final bool raspberryPiConnected;
  final bool pixhawkConnected;
  final bool telemetryConnected;
  final bool videoStreaming;
  final bool aiModelLoaded;
  final bool gpsHealthy;
  final bool batteryHealthy;
  final String message;

  const SystemHealthModel({
    required this.overall,
    required this.raspberryPiConnected,
    required this.pixhawkConnected,
    required this.telemetryConnected,
    required this.videoStreaming,
    required this.aiModelLoaded,
    required this.gpsHealthy,
    required this.batteryHealthy,
    required this.message,
  });

  factory SystemHealthModel.initial() {
    return const SystemHealthModel(
      overall: SystemHealth.warning,
      raspberryPiConnected: false,
      pixhawkConnected: false,
      telemetryConnected: false,
      videoStreaming: false,
      aiModelLoaded: false,
      gpsHealthy: false,
      batteryHealthy: true,
      message: 'Waiting for systems...',
    );
  }

  Map<String,dynamic> toMap() => {
    'overall': overall.name,
    'raspberryPiConnected': raspberryPiConnected,
    'pixhawkConnected': pixhawkConnected,
    'telemetryConnected': telemetryConnected,
    'videoStreaming': videoStreaming,
    'aiModelLoaded': aiModelLoaded,
    'gpsHealthy': gpsHealthy,
    'batteryHealthy': batteryHealthy,
    'message': message,
  };

  factory SystemHealthModel.fromMap(Map<String,dynamic> map){
    return SystemHealthModel(
      overall: SystemHealth.values.firstWhere(
        (e)=>e.name==map['overall'],
        orElse: ()=>SystemHealth.warning,
      ),
      raspberryPiConnected: map['raspberryPiConnected'] ?? false,
      pixhawkConnected: map['pixhawkConnected'] ?? false,
      telemetryConnected: map['telemetryConnected'] ?? false,
      videoStreaming: map['videoStreaming'] ?? false,
      aiModelLoaded: map['aiModelLoaded'] ?? false,
      gpsHealthy: map['gpsHealthy'] ?? false,
      batteryHealthy: map['batteryHealthy'] ?? true,
      message: map['message'] ?? '',
    );
  }

  SystemHealthModel copyWith({
    SystemHealth? overall,
    bool? raspberryPiConnected,
    bool? pixhawkConnected,
    bool? telemetryConnected,
    bool? videoStreaming,
    bool? aiModelLoaded,
    bool? gpsHealthy,
    bool? batteryHealthy,
    String? message,
  }){
    return SystemHealthModel(
      overall: overall ?? this.overall,
      raspberryPiConnected: raspberryPiConnected ?? this.raspberryPiConnected,
      pixhawkConnected: pixhawkConnected ?? this.pixhawkConnected,
      telemetryConnected: telemetryConnected ?? this.telemetryConnected,
      videoStreaming: videoStreaming ?? this.videoStreaming,
      aiModelLoaded: aiModelLoaded ?? this.aiModelLoaded,
      gpsHealthy: gpsHealthy ?? this.gpsHealthy,
      batteryHealthy: batteryHealthy ?? this.batteryHealthy,
      message: message ?? this.message,
    );
  }
}


