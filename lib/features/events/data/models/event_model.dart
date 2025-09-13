
import '../../domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    super.id,
    required super.title,
    required super.description,
    super.location = "",
    required super.colorName,
    required super.startDateTime,
    required super.endDateTime,
    super.reminderTime = 15,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      location: map['location'] as String,
      colorName: map['colorName'] as String,
      startDateTime: map['startDateTime'],
      endDateTime: map['endDateTime'],
      reminderTime: map['reminderTime'] as int? ?? 15,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'colorName': colorName,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'reminderTime': reminderTime,
    };
  }
}
