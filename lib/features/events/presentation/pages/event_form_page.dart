import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/color_mapper.dart';
import '../../domain/entities/event.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../widgets/form_widgets/form_widgets.dart';
import 'location_picker_page.dart';

class EventFormPage extends StatefulWidget {
  final Event? event; // null for add, existing event for edit
  final DateTime? selectedDate; // required for add, optional for edit

  const EventFormPage({
    super.key,
    this.event,
    this.selectedDate,
  }) : assert(event != null || selectedDate != null,
            'Either event (for edit) or selectedDate (for add) must be provided');

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  late Color _selectedColor;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _reminderTime;

  final _colorOptions = kEventColorOptions;
  final _reminderOptions = kReminderOptions;

  bool get isEditing => widget.event != null;
  String get pageTitle => isEditing ? 'Edit Event' : 'Add Event';
  String get buttonText => isEditing ? 'Update Event' : 'Add Event';

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final event = widget.event!;
      _nameController = TextEditingController(text: event.title);
      _descriptionController = TextEditingController(text: event.description);
      _locationController = TextEditingController(text: event.location ?? '');

      _selectedColor = ColorMapper.stringToColor(event.colorName);
      _startTime = TimeOfDay.fromDateTime(event.startDateTime);
      _endTime = TimeOfDay.fromDateTime(event.endDateTime);
      _reminderTime = event.reminderTime;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _locationController = TextEditingController();

      _selectedColor = Colors.blue;
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.now();
      _reminderTime = 15;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  DateTime get eventDate =>
      isEditing ? widget.event!.startDateTime : widget.selectedDate!;

  Future<void> _openLocationPicker() async {
    final String? selectedLocation = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          initialLocation: _locationController.text.isNotEmpty
              ? _locationController.text
              : null,
        ),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _locationController.text = selectedLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
        ),
        title: Text(pageTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 0),
              CustomInput(
                title: 'Event name',
                controller: _nameController,
                hintText: 'Enter event name',
              ),
              const SizedBox(height: 16),
              CustomInput(
                title: 'Event description',
                controller: _descriptionController,
                hintText: 'Enter event description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CustomInput(
                title: 'Event location',
                controller: _locationController,
                hintText: 'Enter location',
                suffixIcon: Icons.location_on,
                onSuffixTap: _openLocationPicker,
              ),
              const SizedBox(height: 16),
              const Text('Priority color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              CustomDropdown<Color>(
                value: _selectedColor,
                items: _colorOptions,
                onChanged: (color) => setState(() => _selectedColor = color),
                itemBuilder: (color) =>
                    Container(width: 20, height: 20, color: color),
                isExpanded: false,
                wrapWithContainer: false,
              ),
              const SizedBox(height: 16),
              const Text('Event time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TimeRangePicker(
                startTime: _startTime,
                endTime: _endTime,
                onStartChanged: (t) => setState(() => _startTime = t),
                onEndChanged: (t) => setState(() => _endTime = t),
              ),
              const SizedBox(height: 16),
              const Text('Reminder',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              CustomDropdown<int>(
                value: _reminderTime,
                items: _reminderOptions.keys.toList(),
                onChanged: (value) => setState(() => _reminderTime = value),
                itemBuilder: (key) => Row(
                  children: [
                    const Icon(Icons.notifications,
                        color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(_reminderOptions[key]!),
                  ],
                ),
                isExpanded: true,
                wrapWithContainer: true,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isNotEmpty) {
                      final start = combineDateAndTime(eventDate, _startTime);
                      final end = combineDateAndTime(eventDate, _endTime);

                      if (end.isBefore(start)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('End time must be after start time'),
                          ),
                        );
                        return;
                      }
                      // 1 << 31 equals 2^31 (range size for signed 32-bit integers) for notification id
                      final int eventId = isEditing
                          ? widget.event!.id!
                          : (DateTime.now().millisecondsSinceEpoch % (1 << 31))
                              .toInt();

                      final event = Event(
                        id: eventId,
                        title: _nameController.text,
                        description: _descriptionController.text,
                        location: _locationController.text,
                        startDateTime: start,
                        endDateTime: end,
                        colorName: ColorMapper.colorToString(_selectedColor),
                        reminderTime: _reminderTime,
                      );

                      if (isEditing) {
                        await NotificationService()
                            .cancelNotification(widget.event!.id!);
                        context
                            .read<EventBloc>()
                            .add(UpdateExistingEvent(event));
                      } else {
                        context.read<EventBloc>().add(AddNewEvent(event));
                      }

                      await NotificationService().scheduleEventReminder(
                        eventId: event.id!,
                        eventTitle: event.title,
                        eventDescription: event.description,
                        eventStartTime: event.startDateTime,
                        reminderMinutes: event.reminderTime,
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }
}
