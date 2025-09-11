
import '../../domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    super.id,
    required super.title,
    required super.description,
    super.location = "",
    required super.color,
    required super.startDateTime,
    required super.endDateTime,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      location: map['location'] as String,
      color: map['color'],
      startDateTime: map['startDateTime'],
      endDateTime: map['endDateTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'color': color,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
    };
  }
}
