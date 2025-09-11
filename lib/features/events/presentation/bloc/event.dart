import 'package:equatable/equatable.dart';
import '../../domain/entities/event.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventEvent {}

class AddNewEvent extends EventEvent {
  final Event event;

  const AddNewEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class UpdateExistingEvent extends EventEvent {
  final Event event;

  const UpdateExistingEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class DeleteExistingEvent extends EventEvent {
  final int id;

  const DeleteExistingEvent(this.id);

  @override
  List<Object?> get props => [id];
}