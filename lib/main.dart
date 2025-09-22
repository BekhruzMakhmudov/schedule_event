import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/events/presentation/bloc/bloc.dart';
import 'features/events/presentation/bloc/event.dart';
import 'features/events/presentation/pages/calendar_page.dart';
import 'service_locator.dart';

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
    final Locale systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final Locale appLocale = systemLocale.languageCode == 'ru' ? const Locale('ru') : const Locale('en');

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
        locale: appLocale,
        supportedLocales: const [
          Locale('en'),
          Locale('ru'),
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
