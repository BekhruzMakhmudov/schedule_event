import 'package:intl/intl.dart';

class DateFormatters {
  static String shortDayOfWeek(DateTime date, {required String locale}) {
    final str = DateFormat('EEE', locale).format(date);
    return str.isNotEmpty ? str[0].toUpperCase() + str.substring(1) : str;
  }
  static String monthName(DateTime date, {required String locale}) {
    final str = DateFormat.MMMM(locale).format(date);
    return str.isNotEmpty ? str[0].toUpperCase() + str.substring(1) : str;
  }
  static String dayOfWeek(DateTime date, {required String locale}) {
    final str = DateFormat.EEEE(locale).format(date);
    return str.isNotEmpty ? str[0].toUpperCase() + str.substring(1) : str;
  }

  static String dayMonth(DateTime date, {required String locale}) {
    final str = DateFormat('d MMMM', locale).format(date);
    final parts = str.split(' ');
    if (parts.length > 1 && parts[1].isNotEmpty) {
      parts[1] = parts[1][0].toUpperCase() + parts[1].substring(1);
      return parts.join(' ');
    }
    return str;
  }
}
