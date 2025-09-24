import 'package:flutter/material.dart';
import 'package:schedule_event/core/utils/color_mapper.dart';
import 'package:schedule_event/core/utils/date_formatters.dart';

import '../../../domain/entities/event.dart';

class CustomCalendar extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final List<Event> events;

  const CustomCalendar({
    super.key,
    this.onDateSelected,
    required this.events,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate = DateTime.now();


  int _getSystemFirstDayOfWeek(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    if (locale.startsWith('ru')) {
      return DateTime.monday;
    }
    return DateTime.sunday;
  }

  List<DateTime?> _getCalendarDays(DateTime month, int firstDayOfWeek) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    int shift = (firstDay.weekday - firstDayOfWeek) % 7;
    if (shift < 0) shift += 7;
    List<DateTime?> days = [];

    for (int i = 0; i < shift; i++) {
      days.add(null);
    }

    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
  final firstDayOfWeek = _getSystemFirstDayOfWeek(context);
  final days = _getCalendarDays(_focusedDate, firstDayOfWeek);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatters.monthName(
                  _focusedDate,
                  locale: Localizations.localeOf(context).toString(),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _focusedDate = DateTime(
                          _focusedDate.year,
                          _focusedDate.month - 1,
                          1,
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _focusedDate = DateTime(
                          _focusedDate.year,
                          _focusedDate.month + 1,
                          1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              // Динамически вычисляем день недели, начиная с системного первого дня
              final weekday = (firstDayOfWeek + i - 1) % 7 + 1;
              // 2020-09-20 - это воскресенье, 2020-09-21 - понедельник и т.д.
              final date = DateTime(2020, 9, 20 + weekday - 7 * ((weekday < 7) ? 0 : 1));
              return Text(
                DateFormatters.shortDayOfWeek(
                  date,
                  locale: Localizations.localeOf(context).toString(),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              );
            }),
          ),
        ),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final date = days[index];
            if (date == null) {
              return const SizedBox();
            }

            final isSelected = _selectedDate != null &&
                _selectedDate!.year == date.year &&
                _selectedDate!.month == date.month &&
                _selectedDate!.day == date.day;

            final isToday = DateTime.now().year == date.year &&
                DateTime.now().month == date.month &&
                DateTime.now().day == date.day;

            final dayEvents = widget.events.where((event) =>
                event.startDateTime.year == date.year &&
                event.startDateTime.month == date.month &&
                event.startDateTime.day == date.day);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
                widget.onDateSelected?.call(date);
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue
                          : (isToday)
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withAlpha(128)
                              : null,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${date.day}",
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (dayEvents.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: dayEvents
                            .take(3)
                            .map(
                              (e) => Container(
                                width: 5,
                                height: 5,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: ColorMapper.stringToColor(e.colorName),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
