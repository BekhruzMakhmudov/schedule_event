import 'package:flutter/material.dart';
import 'package:schedule_event/core/utils/color_mapper.dart';
import '../../domain/entities/event.dart';
import '../pages/event_details_page.dart';

class EventList extends StatefulWidget {
  final List<Event> events;
  final Future<void> Function(int id) onEventDeleted;
  final Function(Event) onEventUpdated;

  const EventList({
    super.key,
    required this.events,
    required this.onEventDeleted,
    required this.onEventUpdated,
  });

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return const Center(
        child: Text(
          'No events for this day',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.events.length,
      itemBuilder: (context, index) {
        final event = widget.events[index];
        return Column(
          children: [
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: ColorMapper.stringToColor(event.colorName),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: ColorMapper.stringToColor(event.colorName).withAlpha(60),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(
                  color:
                      ColorMapper.stringToColor(event.colorName).withAlpha(120),
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Text(
                  event.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ColorMapper.stringToColor(event.colorName),
                      ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ColorMapper.stringToColor(event.colorName)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_filled,
                          size: 16,
                          color: ColorMapper.stringToColor(event.colorName),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.timeRange,
                          style: TextStyle(
                            color: ColorMapper.stringToColor(event.colorName),
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
                            color: ColorMapper.stringToColor(event.colorName),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: TextStyle(
                                color:
                                    ColorMapper.stringToColor(event.colorName),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
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
                        onEventDeleted: widget.onEventDeleted,
                        onEventUpdated: widget.onEventUpdated,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
