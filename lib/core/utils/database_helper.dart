import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../../models/job_application_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'job_tracker.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE applications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company TEXT NOT NULL,
        position TEXT NOT NULL,
        status TEXT NOT NULL,
        applicationDate TEXT NOT NULL,
        notes TEXT,
        jobPortalSource TEXT,
        jobPortalUrl TEXT,
        jobPortalId TEXT,
        additionalData TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE applications ADD COLUMN jobPortalSource TEXT');
      await db.execute('ALTER TABLE applications ADD COLUMN jobPortalUrl TEXT');
      await db.execute('ALTER TABLE applications ADD COLUMN jobPortalId TEXT');
      await db.execute('ALTER TABLE applications ADD COLUMN additionalData TEXT');
    }
  }

  Future<int> insertApplication(JobApplication application) async {
    final db = await database;
    Map<String, dynamic> map = application.toMap();
    if (map['additionalData'] != null) {
      map['additionalData'] = jsonEncode(map['additionalData']);
    }
    return await db.insert('applications', map);
  }

  Future<int> updateApplication(JobApplication application) async {
    final db = await database;
    Map<String, dynamic> map = application.toMap();
    if (map['additionalData'] != null) {
      map['additionalData'] = jsonEncode(map['additionalData']);
    }
    return await db.update(
      'applications',
      map,
      where: 'id = ?',
      whereArgs: [application.id],
    );
  }

  Future<int> deleteApplication(int id) async {
    final db = await database;
    return await db.delete(
      'applications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<JobApplication>> getAllApplications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('applications');
    return List.generate(maps.length, (i) {
      Map<String, dynamic> map = Map<String, dynamic>.from(maps[i]);
      if (map['additionalData'] != null) {
        try {
          map['additionalData'] = jsonDecode(map['additionalData'] as String);
        } catch (e) {
          print('Error decoding additionalData: $e');
          map['additionalData'] = null;
        }
      }
      return JobApplication.fromMap(map);
    });
  }

  Future<Map<String, int>> getStatusCounts() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT status, COUNT(*) as count
      FROM applications
      GROUP BY status
    ''');

    Map<String, int> statusCounts = {};
    for (var row in result) {
      statusCounts[row['status'] as String] = row['count'] as int;
    }

    for (var status in ApplicationStatus.getAllStatuses()) {
      statusCounts.putIfAbsent(status, () => 0);
    }

    return statusCounts;
  }

  Future<List<JobApplication>> getApplicationsByPortal(String portalSource) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'applications',
      where: 'jobPortalSource = ?',
      whereArgs: [portalSource],
    );
    return List.generate(maps.length, (i) => JobApplication.fromMap(maps[i]));
  }
}
