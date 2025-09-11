import '../entities/event.dart';
import '../repositories/event_repository.dart';

class UpdateEvent {
  final EventRepository repository;

  UpdateEvent(this.repository);

  Future<void> call(Event event) async {
    await repository.updateEvent(event);
  }
}
