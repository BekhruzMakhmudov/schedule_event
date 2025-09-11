import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_local_datasource.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventLocalDataSource localDataSource;

  EventRepositoryImpl(this.localDataSource);

  @override
  Future<List<Event>> getEvents() async {
    final models = await localDataSource.getEvents();
    return models;
  }

  @override
  Future<void> addEvent(Event event) async {
    final model = EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      location: event.location,
      color: event.color,
      startDateTime: event.startDateTime,
      endDateTime: event.endDateTime,
    );
    await localDataSource.insertEvent(model);
  }

  @override
  Future<void> updateEvent(Event event) async {
    final model = EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      location: event.location,
      color: event.color,
      startDateTime: event.startDateTime,
      endDateTime: event.endDateTime,
    );
    await localDataSource.updateEvent(model);
  }

  @override
  Future<void> deleteEvent(int id) async {
    await localDataSource.deleteEvent(id);
  }
}