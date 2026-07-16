import 'package:flutter/foundation.dart';

import '../services/video/video_stream_service.dart';
import '../models/camera_settings_model.dart';

class CameraController extends ChangeNotifier {
  CameraController._();
  static final CameraController instance = CameraController._();

  final VideoStreamService video = VideoStreamService.instance;

  CameraSettingsModel settings =
      CameraSettingsModel.defaults();

  Future<void> startStream() async {
    video.configure(settings.streamUrl);
    await video.start();
    notifyListeners();
  }

  Future<void> stopStream() async {
    await video.stop();
    notifyListeners();
  }

  void updateSettings(CameraSettingsModel value) {
    settings = value;
    notifyListeners();
  }
}

