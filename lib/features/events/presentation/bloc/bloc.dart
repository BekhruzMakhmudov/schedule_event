import 'package:flutter_bloc/flutter_bloc.dart';
import 'event.dart';
import 'state.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/add_event.dart';
import '../../domain/usecases/update_event.dart';
import '../../domain/usecases/delete_event.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetEvents getEvents;
  final AddEvent addEvent;
  final UpdateEvent updateEvent;
  final DeleteEvent deleteEvent;

  EventBloc({
    required this.getEvents,
    required this.addEvent,
    required this.updateEvent,
    required this.deleteEvent,
  }) : super(EventInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<AddNewEvent>(_onAddEvent);
    on<UpdateExistingEvent>(_onUpdateEvent);
    on<DeleteExistingEvent>(_onDeleteEvent);
  }

  Future<void> _onLoadEvents(
      LoadEvents event,
      Emitter<EventState> emit,
      ) async {
    emit(EventLoading());
    try {
      final events = await getEvents();
      emit(EventLoaded(events));
    } catch (e) {
      emit(EventError("Failed to load events: $e"));
    }
  }

  Future<void> _onAddEvent(
      AddNewEvent event,
      Emitter<EventState> emit,
      ) async {
    try {
      await addEvent(event.event);
      add(LoadEvents());
    } catch (e) {
      emit(EventError("Failed to add event: $e"));
    }
  }

  Future<void> _onUpdateEvent(
      UpdateExistingEvent event,
      Emitter<EventState> emit,
      ) async {
    try {
      await updateEvent(event.event);
      add(LoadEvents());
    } catch (e) {
      emit(EventError("Failed to update event: $e"));
    }
  }

  Future<void> _onDeleteEvent(
      DeleteExistingEvent event,
      Emitter<EventState> emit,
      ) async {
    try {
      await deleteEvent(event.id);
      add(LoadEvents());
    } catch (e) {
      emit(EventError("Failed to delete event: $e"));
    }
  }
}
