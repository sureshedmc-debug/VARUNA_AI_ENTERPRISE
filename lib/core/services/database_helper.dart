import 'database_service.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Future<int> insertMission(Map<String,dynamic> data) {
    return DatabaseService.instance.insert('missions', data);
  }

  Future<int> insertTelemetry(Map<String,dynamic> data) {
    return DatabaseService.instance.insert('telemetry', data);
  }

  Future<int> insertDetection(Map<String,dynamic> data) {
    return DatabaseService.instance.insert('detections', data);
  }

  Future<int> insertReport(Map<String,dynamic> data) {
    return DatabaseService.instance.insert('reports', data);
  }

  Future<List<Map<String,dynamic>>> getMissions() =>
      DatabaseService.instance.getAll('missions');

  Future<List<Map<String,dynamic>>> getReports() =>
      DatabaseService.instance.getAll('reports');
}

