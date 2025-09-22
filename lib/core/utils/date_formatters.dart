import 'package:intl/intl.dart';

class DateFormatters {
  static String shortDayOfWeek(DateTime date, {String? locale}) {
    final code = locale ?? Intl.getCurrentLocale();
    return DateFormat('EEE', code).format(date);
  }
  static String monthName(DateTime date, {String? locale}) {
    final code = locale ?? Intl.getCurrentLocale();
    return DateFormat.MMMM(code).format(date);
  }
  static String dayOfWeek(DateTime date, {String? locale}) {
    final code = locale ?? Intl.getCurrentLocale();
    return DateFormat.EEEE(code).format(date);
  }

  static String dayMonth(DateTime date, {String? locale}) {
    final code = locale ?? Intl.getCurrentLocale();
    return DateFormat('d MMMM', code).format(date);
  }

}
