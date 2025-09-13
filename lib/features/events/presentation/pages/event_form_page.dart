import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';
import '../../../../core/services/notification_service.dart';

class EventFormPage extends StatefulWidget {
  final Event? event; // null for add, existing event for edit
  final Function(Event) onEventSaved;
  final DateTime? selectedDate; // required for add, optional for edit

  const EventFormPage({
    super.key,
    this.event,
    required this.onEventSaved,
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

  final _colorOptions = [Colors.blue, Colors.orange, Colors.red];
  final _reminderOptions = {
    5: '5 minutes before',
    10: '10 minutes before',
    15: '15 minutes before',
    30: '30 minutes before',
    60: '1 hour before',
    120: '2 hours before',
    1440: '1 day before',
  };

  bool get isEditing => widget.event != null;
  String get pageTitle => isEditing ? 'Edit Event' : 'Add Event';
  String get buttonText => isEditing ? 'Update Event' : 'Add Event';

  @override
  void initState() {
    super.initState();
    
    if (isEditing) {
      // Initialize with existing event data
      final event = widget.event!;
      _nameController = TextEditingController(text: event.title);
      _descriptionController = TextEditingController(text: event.description);
      _locationController = TextEditingController(text: event.location ?? '');
      
      _selectedColor = event.color;
      _startTime = TimeOfDay.fromDateTime(event.startDateTime);
      _endTime = TimeOfDay.fromDateTime(event.endDateTime);
      _reminderTime = event.reminderTime;
    } else {
      // Initialize with default values for new event
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _locationController = TextEditingController();
      
      _selectedColor = Colors.blue;
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.now();
      _reminderTime = 15;
    }
  }


  String _colorToString(Color color) {
    if (color == Colors.blue) return 'blue';
    if (color == Colors.red) return 'red';
    if (color == Colors.orange) return 'orange';
    return 'blue'; // default
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

  DateTime get eventDate => isEditing ? widget.event!.startDateTime : widget.selectedDate!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
              const Text('Event name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter event name',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Event description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter event description',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Event location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Enter location',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  suffixIcon: const Icon(Icons.location_on, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Priority color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButton<Color>(
                value: _selectedColor,
                onChanged: (Color? newValue) {
                  setState(() {
                    _selectedColor = newValue!;
                  });
                },
                alignment: Alignment.center,
                underline: Container(),
                dropdownColor: Colors.white,
                items:
                    _colorOptions.map<DropdownMenuItem<Color>>((Color color) {
                  return DropdownMenuItem<Color>(
                    value: color,
                    child: Container(width: 20, height: 20, color: color),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Event time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (time != null) {
                          setState(() => _startTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _startTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('-', style: TextStyle(fontSize: 18)),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                        );
                        if (time != null) {
                          setState(() => _endTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _endTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Reminder',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<int>(
                  value: _reminderTime,
                  onChanged: (int? newValue) {
                    setState(() {
                      _reminderTime = newValue!;
                    });
                  },
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  underline: Container(),
                  items: _reminderOptions.entries
                      .map<DropdownMenuItem<int>>((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Row(
                        children: [
                          const Icon(Icons.notifications,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(entry.value),
                        ],
                      ),
                    );
                  }).toList(),
                ),
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

                      final eventId = isEditing 
                          ? widget.event!.id 
                          : DateTime.now().millisecondsSinceEpoch;

                      final event = Event(
                        id: eventId,
                        title: _nameController.text,
                        description: _descriptionController.text,
                        location: _locationController.text,
                        startDateTime: start,
                        endDateTime: end,
                        colorName: _colorToString(_selectedColor),
                        reminderTime: _reminderTime,
                      );

                      // Handle notifications
                      if (isEditing) {
                        // Cancel old notification and schedule new one
                        await NotificationService().cancelNotification(widget.event!.id!);
                      }
                      
                      await NotificationService().scheduleEventReminder(
                        eventId: event.id!,
                        eventTitle: event.title,
                        eventDescription: event.description,
                        eventStartTime: event.startDateTime,
                        reminderMinutes: event.reminderTime,
                      );

                      widget.onEventSaved(event);
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
