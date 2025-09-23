import 'package:intl/intl.dart';

class DateFormatters {
  static String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }
  static String shortDayOfWeek(DateTime date, {required String locale}) {
    final str = DateFormat('EEE', locale).format(date);
    return _capitalize(str);
  }
  static String monthName(DateTime date, {required String locale}) {
    final str = DateFormat.MMMM(locale).format(date);
    return _capitalize(str);
  }
  static String dayOfWeek(DateTime date, {required String locale}) {
    final str = DateFormat.EEEE(locale).format(date);
    return _capitalize(str);
  }
  static String dayMonth(DateTime date, {required String locale}) {
    final str = DateFormat('d MMMM', locale).format(date);
    final parts = str.split(' ');
    if (parts.length > 1) {
      parts[1] = _capitalize(parts[1]);
      return parts.join(' ');
    }
    return str;
  }
}