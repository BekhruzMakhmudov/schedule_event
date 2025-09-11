import '../entities/event.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<void> addEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(int id);
}