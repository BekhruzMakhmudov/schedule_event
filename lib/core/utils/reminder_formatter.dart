String formatReminderTime(int minutes) {
  if (minutes >= 1440) {
    final days = minutes ~/ 1440;
    return '$days day${days == 1 ? '' : 's'} before';
  } else if (minutes >= 60) {
    final hours = minutes ~/ 60;
    return '$hours hour${hours == 1 ? '' : 's'} before';
  } else {
    return '$minutes minute${minutes == 1 ? '' : 's'} before';
  }
}
