import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _dbName = 'field_os.db';
  static const _dbVersion = 1;

  static const ticketsTable = 'tickets';
  static const serviceReportsTable = 'service_reports';

  static Database? _database;

  DatabaseHelper._init();

  static Future<Database> get db async {
    _database ??= await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  @visibleForTesting
  static Future<Database> openInMemory() => openDatabase(
    inMemoryDatabasePath,
    version: _dbVersion,
    onConfigure: _onConfigure,
    onCreate: _onCreate,
  );

  static Future<void> _onConfigure(Database db) =>
      db.execute('PRAGMA foreign_keys = ON');

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $ticketsTable(
        id INTEGER PRIMARY KEY,
        client_code TEXT NOT NULL,
        client_name TEXT NOT NULL,
        reported_category TEXT NOT NULL,
        problem_description TEXT NOT NULL,
        client_address TEXT NOT NULL,
        neighborhood TEXT NOT NULL,
        city TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $serviceReportsTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id INTEGER,
        ticket_id INTEGER NOT NULL UNIQUE,
        technical_category TEXT NOT NULL,
        procedure_description TEXT NOT NULL,
        resolved_at TEXT NOT NULL,
        photo_path TEXT,
        photo_url TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        sync_error TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (ticket_id) REFERENCES $ticketsTable(id)
      )
    ''');
  }
}
