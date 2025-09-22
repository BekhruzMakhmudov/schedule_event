import 'package:flutter/material.dart';

class TimeRangePicker extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;

  const TimeRangePicker({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  Future<void> _pickTime(BuildContext context, {
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onChanged,
  }) async {
    final time = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (time != null) onChanged(time);
  }

  @override
  Widget build(BuildContext context) {
    Widget _timeBox(String text, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );

    return Row(
      children: [
        Expanded(
          child: _timeBox(
            startTime.format(context),
            () => _pickTime(
              context,
              initial: startTime,
              onChanged: onStartChanged,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('-', style: TextStyle(fontSize: 18)),
        ),
        Expanded(
          child: _timeBox(
            endTime.format(context),
            () => _pickTime(
              context,
              initial: endTime,
              onChanged: onEndChanged,
            ),
          ),
        ),
      ],
    );
  }
}
