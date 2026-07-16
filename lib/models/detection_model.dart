class DetectionModel {
  final int? id;
  final String label;
  final double confidence;
  final double left;
  final double top;
  final double width;
  final double height;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? imagePath;

  const DetectionModel({
    this.id,
    required this.label,
    required this.confidence,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'confidence': confidence,
      'left': left,
      'top': top,
      'width': width,
      'height': height,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory DetectionModel.fromMap(Map<String, dynamic> map) {
    return DetectionModel(
      id: map['id'] as int?,
      label: map['label'] ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0,
      left: (map['left'] as num?)?.toDouble() ?? 0,
      top: (map['top'] as num?)?.toDouble() ?? 0,
      width: (map['width'] as num?)?.toDouble() ?? 0,
      height: (map['height'] as num?)?.toDouble() ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      imagePath: map['imagePath'],
    );
  }

  DetectionModel copyWith({
    int? id,
    String? label,
    double? confidence,
    double? left,
    double? top,
    double? width,
    double? height,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? imagePath,
  }) {
    return DetectionModel(
      id: id ?? this.id,
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      left: left ?? this.left,
      top: top ?? this.top,
      width: width ?? this.width,
      height: height ?? this.height,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

