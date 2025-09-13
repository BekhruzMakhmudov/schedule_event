import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../models/event_model.dart';
import '../../../../core/database/app_database.dart';

class EventRepositoryImpl implements EventRepository {
  final AppDatabase _database = AppDatabase.instance;

  // Convert Color to string for database storage
  String _colorToString(Color color) {
    if (color == Colors.blue) return 'blue';
    if (color == Colors.red) return 'red';
    if (color == Colors.orange) return 'orange';
    return 'blue'; // default
  }


  // Convert DateTime to milliseconds for database storage
  int _dateTimeToInt(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  // Convert milliseconds to DateTime from database
  DateTime _intToDateTime(int milliseconds) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  @override
  Future<List<Event>> getEvents() async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query('events');

    return List.generate(maps.length, (i) {
      return EventModel(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'] ?? '',
        location: maps[i]['location'] ?? '',
        colorName: maps[i]['colorName'] as String,
        startDateTime: _intToDateTime(maps[i]['startDateTime']),
        endDateTime: _intToDateTime(maps[i]['endDateTime']),
        reminderTime: maps[i]['reminderTime'] ?? 15,
      );
    });
  }

  @override
  Future<Event?> getEventById(int id) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return EventModel(
        id: maps[0]['id'],
        title: maps[0]['title'],
        description: maps[0]['description'] ?? '',
        location: maps[0]['location'] ?? '',
        colorName: maps[0]['colorName'] as String,
        startDateTime: _intToDateTime(maps[0]['startDateTime']),
        endDateTime: _intToDateTime(maps[0]['endDateTime']),
        reminderTime: maps[0]['reminderTime'] ?? 15,
      );
    }
    return null;
  }

  @override
  Future<List<Event>> getEventsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'startDateTime >= ? AND startDateTime <= ?',
      whereArgs: [_dateTimeToInt(startOfDay), _dateTimeToInt(endOfDay)],
      orderBy: 'startDateTime ASC',
    );

    return List.generate(maps.length, (i) {
      return EventModel(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'] ?? '',
        location: maps[i]['location'] ?? '',
        colorName: maps[i]['colorName'] as String,
        startDateTime: _intToDateTime(maps[i]['startDateTime']),
        endDateTime: _intToDateTime(maps[i]['endDateTime']),
        reminderTime: maps[i]['reminderTime'] ?? 15,
      );
    });
  }

  @override
  Future<void> addEvent(Event event) async {
    final db = await _database.database;
    
    final eventData = {
      'title': event.title,
      'description': event.description,
      'location': event.location ?? '',
      'colorName': _colorToString(event.color),
      'startDateTime': _dateTimeToInt(event.startDateTime),
      'endDateTime': _dateTimeToInt(event.endDateTime),
      'reminderTime': event.reminderTime,
    };

    if (event.id != null) {
      eventData['id'] = event.id!;
    }

    await db.insert('events', eventData);
  }

  @override
  Future<int> updateEvent(Event event) async {
    final db = await _database.database;
    
    final eventData = {
      'title': event.title,
      'description': event.description,
      'location': event.location ?? '',
      'colorName': _colorToString(event.color),
      'startDateTime': _dateTimeToInt(event.startDateTime),
      'endDateTime': _dateTimeToInt(event.endDateTime),
      'reminderTime': event.reminderTime,
    };

    return await db.update(
      'events',
      eventData,
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  @override
  Future<int> deleteEvent(int id) async {
    final db = await _database.database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> insertSampleData() async {
    final events = await getEvents();
    if (events.isEmpty) {
      // Insert sample data only if database is empty
      final sampleEvents = [
        Event(
          id: null,
          title: 'Watching Football',
          description: 'Manchester United vs Arsenal (Premier League)',
          location: 'Stamford Bridge',
          startDateTime: DateTime.parse("2025-09-28 17:00:00"),
          endDateTime: DateTime.parse("2025-09-28 18:30:00"),
          colorName: 'blue',
          reminderTime: 15,
        ),
        Event(
          id: null,
          title: 'Deadline Project UI Website',
          description: 'Flutter Page Card and Wishlist',
          location: '',
          startDateTime: DateTime.parse("2025-09-28 21:00:00"),
          endDateTime: DateTime.parse("2025-09-28 22:30:00"),
          colorName: 'red',
          reminderTime: 30,
        ),
        Event(
          id: null,
          title: 'Meeting Client (Japan)',
          description: 'Android App and website online shop',
          location: '',
          startDateTime: DateTime.parse("2025-09-28 23:15:00"),
          endDateTime: DateTime.parse("2025-09-29 00:45:00"),
          colorName: 'orange',
          reminderTime: 60,
        ),
      ];

      for (final event in sampleEvents) {
        await addEvent(event);
      }
    }
  }
}