import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('events.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        location TEXT,
        colorName TEXT NOT NULL,
        startDateTime INTEGER NOT NULL,
        endDateTime INTEGER NOT NULL,
        reminderTime INTEGER DEFAULT 15
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventId INTEGER NOT NULL,
        title TEXT NOT NULL,
        body TEXT,
        scheduledAt INTEGER NOT NULL,
        deliveredAt INTEGER NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS events');
      await _createDB(db, newVersion);
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          eventId INTEGER NOT NULL,
          title TEXT NOT NULL,
          body TEXT,
          scheduledAt INTEGER NOT NULL,
          deliveredAt INTEGER NOT NULL,
          isRead INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }
}
