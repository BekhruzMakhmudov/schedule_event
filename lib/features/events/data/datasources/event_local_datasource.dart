import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../models/event_model.dart';

class EventLocalDataSource {
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<int> insertEvent(EventModel event) async {
    final db = await _db;
    return await db.insert('events', event.toMap());
  }

  Future<List<EventModel>> getEvents() async {
    final db = await _db;
    final maps = await db.query('events', orderBy: 'date ASC');
    return maps.map((e) => EventModel.fromMap(e)).toList();
  }

  Future<int> updateEvent(EventModel event) async {
    final db = await _db;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await _db;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}