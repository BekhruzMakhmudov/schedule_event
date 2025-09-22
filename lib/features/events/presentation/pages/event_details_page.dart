import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schedule_event/l10n/app_localizations.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/color_mapper.dart';
import '../../../../core/utils/reminder_formatter.dart';
import '../../domain/entities/event.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../widgets/icon_text.dart';
import 'event_form_page.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late Event currentEvent;

  @override
  void initState() {
    super.initState();
    currentEvent = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorMapper.stringToColor(currentEvent.colorName),
        leading: InkWell(
          child: Container(
            margin: const EdgeInsets.only(left: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chevron_left, color: Colors.black),
          ),
          onTap: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventFormPage(
                    event: currentEvent,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.editEvent,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorMapper.stringToColor(currentEvent.colorName),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentEvent.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  currentEvent.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 4),
                IconText(
                  icon: Icons.access_time,
                  text: currentEvent.timeRange,
                  color: Colors.white,
                  iconSize: 20,
                  fontSize: 16,
                ),
                const SizedBox(height: 8),
                if (currentEvent.location!.isNotEmpty)
                  IconText(
                    icon: Icons.location_on,
                    text: currentEvent.location!,
                    color: Colors.white,
                    iconSize: 20,
                    fontSize: 16,
                    expandText: true,
                    maxLines: 2,
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.reminder,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatReminderTime(context, currentEvent.reminderTime),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.description,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentEvent.description.isNotEmpty
                        ? currentEvent.description
                        : AppLocalizations.of(context)!.noDescription,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                  AppLocalizations.of(context)!.deleteEvent),
                              content: Text(AppLocalizations.of(context)!
                                  .deleteEventConfirm),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                      AppLocalizations.of(context)!.cancel),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (currentEvent.id != null) {
                                      // Cancel notification for this event
                                      await NotificationService()
                                          .cancelNotification(currentEvent.id!);
                                      context.read<EventBloc>().add(
                                          DeleteExistingEvent(
                                              currentEvent.id!));
                                    }
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.deleteEvent,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.deleteEvent,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
