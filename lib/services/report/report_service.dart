import 'package:flutter/foundation.dart';

class ReportService extends ChangeNotifier {
  ReportService._();
  static final ReportService instance = ReportService._();

  Future<String> createMissionReport({
    required String missionName,
    required Duration duration,
    required double distanceMeters,
    required int detections,
  }) async {
    final filePath =
        'reports/${missionName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    return filePath;
  }
}

