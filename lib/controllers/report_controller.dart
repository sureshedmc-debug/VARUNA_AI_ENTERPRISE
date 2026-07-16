import 'package:flutter/foundation.dart';

import '../services/report/report_service.dart';
import '../core/services/logger_service.dart';

class ReportController extends ChangeNotifier {
  ReportController._();
  static final ReportController instance = ReportController._();

  Future<String> generate({
    required String missionName,
    required Duration duration,
    required double distanceMeters,
    required int detections,
  }) async {
    LoggerService.instance.info('Generating report...');

    final path = await ReportService.instance.createMissionReport(
      missionName: missionName,
      duration: duration,
      distanceMeters: distanceMeters,
      detections: detections,
    );

    LoggerService.instance.info('Report created: $path');

    notifyListeners();
    return path;
  }
}

