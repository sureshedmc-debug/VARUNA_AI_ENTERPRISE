class CameraSettingsModel {
  final String streamUrl;
  final int width;
  final int height;
  final int fps;
  final bool aiOverlayEnabled;
  final bool recordVideo;
  final bool showBoundingBoxes;

  const CameraSettingsModel({
    required this.streamUrl,
    required this.width,
    required this.height,
    required this.fps,
    required this.aiOverlayEnabled,
    required this.recordVideo,
    required this.showBoundingBoxes,
  });

  factory CameraSettingsModel.defaults() {
    return const CameraSettingsModel(
      streamUrl: '',
      width: 1280,
      height: 720,
      fps: 30,
      aiOverlayEnabled: true,
      recordVideo: false,
      showBoundingBoxes: true,
    );
  }

  Map<String,dynamic> toMap() => {
    'streamUrl': streamUrl,
    'width': width,
    'height': height,
    'fps': fps,
    'aiOverlayEnabled': aiOverlayEnabled,
    'recordVideo': recordVideo,
    'showBoundingBoxes': showBoundingBoxes,
  };

  factory CameraSettingsModel.fromMap(Map<String,dynamic> map){
    return CameraSettingsModel(
      streamUrl: map['streamUrl'] ?? '',
      width: map['width'] ?? 1280,
      height: map['height'] ?? 720,
      fps: map['fps'] ?? 30,
      aiOverlayEnabled: map['aiOverlayEnabled'] ?? true,
      recordVideo: map['recordVideo'] ?? false,
      showBoundingBoxes: map['showBoundingBoxes'] ?? true,
    );
  }

  CameraSettingsModel copyWith({
    String? streamUrl,
    int? width,
    int? height,
    int? fps,
    bool? aiOverlayEnabled,
    bool? recordVideo,
    bool? showBoundingBoxes,
  }) {
    return CameraSettingsModel(
      streamUrl: streamUrl ?? this.streamUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      fps: fps ?? this.fps,
      aiOverlayEnabled: aiOverlayEnabled ?? this.aiOverlayEnabled,
      recordVideo: recordVideo ?? this.recordVideo,
      showBoundingBoxes: showBoundingBoxes ?? this.showBoundingBoxes,
    );
  }
}

