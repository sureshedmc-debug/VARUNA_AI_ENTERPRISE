import 'database_service.dart';
import 'logger_service.dart';
import 'package:flutter/foundation.dart';


class AppInitializer {
  AppInitializer._();
  static final AppInitializer instance = AppInitializer._();

  Future<void> initialize() async {
    LoggerService.instance.info('Initializing VARUNA AI...');

    if (!kIsWeb) {
      await DatabaseService.instance.initialize();
    }

    LoggerService.instance.info('Application Ready');
  }
}

