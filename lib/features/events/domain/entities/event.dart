import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class Event extends Equatable {
  final int? id;
  final String title;
  final String description;
  final String? location;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final Color color;
  final int reminderTime;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    this.location = "",
    required this.startDateTime,
    required this.endDateTime,
    required this.color,
    this.reminderTime = 15,
  });

  String get timeRange =>
      '${DateFormat('HH:mm').format(startDateTime)}-${DateFormat('HH:mm').format(endDateTime)}';

  String get reminderTimeFormatted {
    if (reminderTime >= 1440) {
      final days = reminderTime ~/ 1440;
      return '$days day${days == 1 ? '' : 's'} before';
    } else if (reminderTime >= 60) {
      final hours = reminderTime ~/ 60;
      return '$hours hour${hours == 1 ? '' : 's'} before';
    } else {
      return '$reminderTime minute${reminderTime == 1 ? '' : 's'} before';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        location,
        color,
        startDateTime,
        endDateTime,
        reminderTime
      ];
}
