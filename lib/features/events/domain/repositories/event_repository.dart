import '../entities/event.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<Event?> getEventById(int id);
  Future<List<Event>> getEventsByDate(DateTime date);
  Future<void> addEvent(Event event);
  Future<int> updateEvent(Event event);
  Future<int> deleteEvent(int id);
  Future<void> insertSampleData();
}