import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schedule_event/core/services/notification_service.dart';
import 'package:schedule_event/core/theme/app_theme.dart';
import 'package:schedule_event/features/events/presentation/bloc/bloc.dart';
import 'package:schedule_event/features/events/presentation/bloc/event.dart';
import 'package:schedule_event/features/events/presentation/pages/calendar_page.dart';
import 'package:schedule_event/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventBloc>(
      create: (context) {
        return getIt<EventBloc>()..add(LoadEvents());
      },
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const CalendarPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
