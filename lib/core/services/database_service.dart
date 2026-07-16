import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Database get database {
    if (_database == null) {
      throw StateError('Database not initialized.');
    }
    return _database!;
  }

  Future<void> initialize() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();

    _database = await openDatabase(
      join(dbPath, 'varuna_ai.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
CREATE TABLE missions(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT,
type TEXT,
status TEXT,
waypointCount INTEGER,
startTime TEXT,
endTime TEXT
)
""");

        await db.execute("""
CREATE TABLE telemetry(
id INTEGER PRIMARY KEY AUTOINCREMENT,
timestamp TEXT,
latitude REAL,
longitude REAL,
altitude REAL,
speed REAL,
heading REAL,
battery REAL,
satellites INTEGER,
flightMode TEXT,
armed INTEGER
)
""");

        await db.execute("""
CREATE TABLE detections(
id INTEGER PRIMARY KEY AUTOINCREMENT,
label TEXT,
confidence REAL,
latitude REAL,
longitude REAL,
imagePath TEXT,
timestamp TEXT
)
""");

        await db.execute("""
CREATE TABLE reports(
id INTEGER PRIMARY KEY AUTOINCREMENT,
missionName TEXT,
createdAt TEXT,
reportPath TEXT
)
""");
      },
    );
  }

  Future<int> insert(String table, Map<String,dynamic> values) =>
      database.insert(table, values);

  Future<List<Map<String,dynamic>>> getAll(String table) =>
      database.query(table);

  Future<int> update(String table, Map<String,dynamic> values, int id) =>
      database.update(table, values, where: 'id=?', whereArgs: [id]);

  Future<int> delete(String table, int id) =>
      database.delete(table, where: 'id=?', whereArgs: [id]);

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}

