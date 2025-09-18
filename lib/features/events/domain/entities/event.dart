import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class Event extends Equatable {
  final int? id;
  final String title;
  final String description;
  final String? location;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String colorName;
  final int reminderTime;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    this.location = "",
    required this.startDateTime,
    required this.endDateTime,
    required this.colorName,
    this.reminderTime = 15,
  });

  String get timeRange =>
      '${DateFormat('HH:mm').format(startDateTime)}-${DateFormat('HH:mm').format(endDateTime)}';

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        location,
        colorName,
        startDateTime,
        endDateTime,
        reminderTime
      ];
}
