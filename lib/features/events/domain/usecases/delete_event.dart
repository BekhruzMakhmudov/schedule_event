import '../repositories/event_repository.dart';

class DeleteEvent {
  final EventRepository repository;

  DeleteEvent(this.repository);

  Future<void> call(int id) async {
    await repository.deleteEvent(id);
  }
}
