import 'package:flutter/cupertino.dart';
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

  Future<void> _showScrollablePicker(
    BuildContext context, {
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onChanged,
  }) async {
    int selectedHour = initial.hour;
    int selectedMinute = initial.minute;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Row(
            children: [
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedHour,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (i) => selectedHour = i,
                  children: List.generate(
                    24,
                    (i) => Center(child: Text(i.toString().padLeft(2, '0'))),
                  ),
                ),
              ),
              const Text(":", style: TextStyle(fontSize: 24)),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedMinute,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (i) => selectedMinute = i,
                  children: List.generate(
                    60,
                    (i) => Center(child: Text(i.toString().padLeft(2, '0'))),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  Navigator.pop(context);
                  onChanged(TimeOfDay(hour: selectedHour, minute: selectedMinute));
                },
              ),
            ],
          ),
        );
      },
    );
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
            () => _showScrollablePicker(
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
            () => _showScrollablePicker(
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