import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schedule_event/service_locator.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../../presentation/bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/state.dart';
import '../widgets/calendar_widgets/calendar_widgets.dart';
import 'event_form_page.dart';
import 'notification_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with WidgetsBindingObserver {
  DateTime _selectedDate = DateTime.now();
  int _unreadCount = 0;
  final NotificationService _notificationService = NotificationService();

  String get _dayOfWeek => DateFormatters.dayOfWeek(_selectedDate);
  String get _formattedDate => DateFormatters.dayMonth(_selectedDate);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initData();
    _loadUnreadCount();
    _notificationService.updateAppBadge();
  }

  Future<void> _initData() async {
    if (kDebugMode) {
      await getIt<EventRepository>().insertSampleData();
    }
    if (!mounted) return;
    context.read<EventBloc>().add(LoadEvents());
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

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (!mounted) return;
    setState(() {
      _unreadCount = count;
    });
  }

  List<Event> _getEventsForDay(List<Event> all, DateTime day) {
    return all.where((event) {
      return event.startDateTime.year == day.year &&
          event.startDateTime.month == day.month &&
          event.startDateTime.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: CalendarAppBarTitle(
          dayOfWeek: _dayOfWeek,
          formattedDate: _formattedDate,
          selectedDate: _selectedDate,
          onSelectedDateChanged: (newDate) {
            setState(() => _selectedDate = newDate);
          },
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
            return BlocBuilder<EventBloc, EventState>(
              builder: (context, state) {
                final allEvents =
                    state is EventLoaded ? state.events : <Event>[];
                final eventsForSelectedDate =
                    _getEventsForDay(allEvents, _selectedDate);

                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomCalendar(
                        events: allEvents,
                        onDateSelected: (date) {
                          setState(() => _selectedDate = date);
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
