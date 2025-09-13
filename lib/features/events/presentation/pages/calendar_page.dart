// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';
import '../widgets/custom_calendar.dart';
import 'event_form_page.dart';
import 'event_details_page.dart';
import '../../domain/repositories/event_repository.dart';
import '../../data/repositories/event_repository_impl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
  List<Event> _events = [];
  final EventRepository _eventRepository = EventRepositoryImpl();
  bool _isLoading = true;

  String get _dayOfWeek {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[_selectedDate.weekday - 1];
  }

  String get _formattedDate {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${_selectedDate.day} ${months[_selectedDate.month - 1]}';
  }

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _eventRepository.insertSampleData();
      final events = await _eventRepository.getEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading events: $e')),
        );
      }
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      return event.startDateTime.year == day.year &&
          event.startDateTime.month == day.month &&
          event.startDateTime.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final eventsForSelectedDate = _getEventsForDay(_selectedDate);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Text(
                _dayOfWeek,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formattedDate,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton(
                    value: _selectedDate.year,
                    items: [
                      for (var year = 1950; year <= 2950; year++)
                        DropdownMenuItem(
                          value: year,
                          child: Text(
                            '$year',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                    ],
                    isDense: true,
                    underline: Container(),
                    dropdownColor: Colors.white,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedDate = DateTime(
                            value,
                            _selectedDate.month,
                            _selectedDate.day,
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
              Positioned(
                right: 15,
                top: 15,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomCalendar(
                        events: _events,
                        onDateSelected: (date) {
                          setState(() => _selectedDate = date);
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight * 0.3,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Schedule',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    await Future.delayed(
                                        const Duration(milliseconds: 100));

                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EventFormPage(
                                            onEventSaved: (event) async {
                                              await _eventRepository.addEvent(event);
                                              _loadEvents();
                                            },
                                            selectedDate: _selectedDate,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    '+ Add Event',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: constraints.maxHeight,
                              child: eventsForSelectedDate.isEmpty
                                  ? Text(
                                    'No events for this day',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  )
                                  : ListView.builder(
                                      itemCount: eventsForSelectedDate.length,
                                      itemBuilder: (context, index) {
                                        final event = eventsForSelectedDate[index];
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            color: event.color.withAlpha(60),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: event.color.withAlpha(120),
                                              width: 1,
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.all(16),
                                            title: Text(
                                              event.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: event.color,
                                                  ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event.description,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(color: event.color),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time_filled,
                                                      size: 16,
                                                      color: event.color,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      event.timeRange,
                                                      style: TextStyle(
                                                        color: event.color,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    if (event.location != null &&
                                                        event.location!.isNotEmpty) ...[
                                                      Icon(
                                                        Icons.location_on,
                                                        size: 16,
                                                        color: event.color,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        event.location!,
                                                        style: TextStyle(
                                                          color: event.color,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EventDetailsPage(
                                                    event: event,
                                                    onEventDeleted: () async {
                                                      await _eventRepository.deleteEvent(event.id!);
                                                      _loadEvents();
                                                    },
                                                    onEventUpdated: (updatedEvent) async {
                                                      await _eventRepository.updateEvent(updatedEvent);
                                                      _loadEvents();
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}