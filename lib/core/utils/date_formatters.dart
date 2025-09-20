import 'package:intl/intl.dart';

class DateFormatters {
  static String dayOfWeek(DateTime date, {String? locale}) {
    final code = locale ?? Intl.getCurrentLocale();
    return DateFormat.EEEE(code).format(date);
    }

  static String dayMonth(DateTime date, {String? locale}) {
    final code = locale ?? Intl.getCurrentLocale();
    return DateFormat('d MMMM', code).format(date);
  }
}
