import '../controllers/camera_controller.dart';
import '../core/services/theme_service.dart';
import '../models/camera_settings_model.dart';
import 'package:flutter/material.dart';

class SettingsBinding {
  SettingsBinding._();
  static final SettingsBinding instance = SettingsBinding._();

  void applyCameraSettings(CameraSettingsModel settings) {
    CameraController.instance.updateSettings(settings);
  }

  void setTheme(ThemeMode mode) {
    ThemeService.instance.setThemeMode(mode);
  }
}

