import 'package:flutter/material.dart';
import 'package:schedule_event/l10n/app_localizations.dart';

String formatReminderTime(BuildContext context, int minutes) {
  final loc = AppLocalizations.of(context)!;
  switch (minutes) {
    case 5:
      return loc.reminderBefore('5', loc.minutes);
    case 10:
      return loc.reminderBefore('10', loc.minutes);
    case 15:
      return loc.reminderBefore('15', loc.minutes);
    case 30:
      return loc.reminderBefore('30', loc.minutes);
    case 60:
      return loc.reminderBefore('1', loc.hour);
    case 120:
      return loc.reminderBefore('2', loc.hours);
    case 1440:
      return loc.reminderBefore('1', loc.day);
    default:
      return loc.reminderBefore(minutes.toString(), loc.minutes);
  }
}
