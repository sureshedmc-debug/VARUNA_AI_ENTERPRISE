class SettingsModel {
  final String raspberryPiIp;
  final int raspberryPiPort;
  final String cameraUrl;
  final bool darkMode;

  const SettingsModel({
    required this.raspberryPiIp,
    required this.raspberryPiPort,
    required this.cameraUrl,
    required this.darkMode,
  });

  factory SettingsModel.defaults() {
    return const SettingsModel(
      raspberryPiIp: '',
      raspberryPiPort: 8000,
      cameraUrl: '',
      darkMode: false,
    );
  }

  SettingsModel copyWith({
    String? raspberryPiIp,
    int? raspberryPiPort,
    String? cameraUrl,
    bool? darkMode,
  }) {
    return SettingsModel(
      raspberryPiIp: raspberryPiIp ?? this.raspberryPiIp,
      raspberryPiPort: raspberryPiPort ?? this.raspberryPiPort,
      cameraUrl: cameraUrl ?? this.cameraUrl,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  Map<String,dynamic> toMap() => {
    'raspberryPiIp': raspberryPiIp,
    'raspberryPiPort': raspberryPiPort,
    'cameraUrl': cameraUrl,
    'darkMode': darkMode,
  };

  factory SettingsModel.fromMap(Map<String,dynamic> map){
    return SettingsModel(
      raspberryPiIp: map['raspberryPiIp'] ?? '',
      raspberryPiPort: map['raspberryPiPort'] ?? 8000,
      cameraUrl: map['cameraUrl'] ?? '',
      darkMode: map['darkMode'] ?? false,
    );
  }
}

