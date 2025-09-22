// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Event Scheduler';

  @override
  String get calendar => 'Calendar';

  @override
  String get eventDetails => 'Event Details';

  @override
  String get addEvent => 'Add Event';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String get location => 'Location';

  @override
  String get notification => 'Notification';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get reminder => 'Reminder';

  @override
  String get selectedLocation => 'Selected Location';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get tapToSelectLocation => 'Tap to select a location';

  @override
  String locationNotFound(Object query) {
    return 'Location \'$query\' not found';
  }

  @override
  String get eventReminders => 'Event Reminders';

  @override
  String get notificationsForUpcomingEvents => 'Notifications for upcoming events';

  @override
  String eventStartsIn(Object description, Object reminder) {
    return 'Event starts in $reminder $description';
  }

  @override
  String get confirmLocation => 'Confirm Location';

  @override
  String get searchLocationHint => 'Search for a location...';

  @override
  String get description => 'Description';

  @override
  String get noDescription => 'No description provided';

  @override
  String get deleteEventConfirm => 'Are you sure you want to delete this event?';

  @override
  String get eventName => 'Event name';

  @override
  String get enterEventName => 'Enter event name';

  @override
  String get eventDescription => 'Event description';

  @override
  String get enterEventDescription => 'Enter event description';

  @override
  String get eventLocation => 'Event location';

  @override
  String get enterLocation => 'Enter location';

  @override
  String get priorityColor => 'Priority color';

  @override
  String get eventTime => 'Event time';

  @override
  String get endTimeAfterStart => 'End time must be after start time';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get markRead => 'Mark read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noEventsForDay => 'No events for this day';

  @override
  String get minutes => 'minutes';

  @override
  String get hour => 'hour';

  @override
  String get hours => 'hours';

  @override
  String get day => 'day';

  @override
  String reminderBefore(Object count, Object unit) {
    return '$count $unit before';
  }

  @override
  String get schedule => 'Schedule';
}
