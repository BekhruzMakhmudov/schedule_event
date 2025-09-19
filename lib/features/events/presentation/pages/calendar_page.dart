// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';
import '../widgets/custom_calendar.dart';
import 'event_form_page.dart';
import '../../domain/repositories/event_repository.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../widgets/event_list.dart';
import '../../../../core/services/notification_service.dart';
import 'notification_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with WidgetsBindingObserver {
  DateTime _selectedDate = DateTime.now();
  List<Event> _events = [];
  final EventRepository _eventRepository = EventRepositoryImpl();
  bool _isLoading = true;
  int _unreadCount = 0;
  final NotificationService _notificationService = NotificationService();

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

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (!mounted) return;
    setState(() {
      _unreadCount = count;
    });
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
    WidgetsBinding.instance.addObserver(this);
    _loadEvents();
    _loadUnreadCount();
    _notificationService.updateAppBadge();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUnreadCount();
      _notificationService.updateAppBadge();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _notificationService.updateAppBadge();
    }
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
        scrolledUnderElevation: 0,
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
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationPage()),
                  );
                  await _loadUnreadCount();
                },
              ),
              if (_unreadCount > 0)
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
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Fixed calendar section
                  CustomCalendar(
                    events: _events,
                    onDateSelected: (date) {
                      setState(() => _selectedDate = date);
                    },
                  ),
                  // Fixed header section
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
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
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: EventList(
                        events: eventsForSelectedDate,
                        onEventDeleted: (int id) async {
                          await _eventRepository.deleteEvent(id);
                          await _loadEvents();
                        },
                        onEventUpdated: (updatedEvent) async {
                          await _eventRepository.updateEvent(updatedEvent);
                          _loadEvents();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
