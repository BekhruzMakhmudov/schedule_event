import '../entities/event.dart';
import '../repositories/event_repository.dart';

class AddEvent {
  final EventRepository repository;

  AddEvent(this.repository);

  Future<void> call(Event event) async {
    await repository.addEvent(event);
  }
}
