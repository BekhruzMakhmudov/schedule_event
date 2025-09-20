import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/bloc.dart';
import '../../bloc/state.dart';

class CalendarAppBarTitle extends StatelessWidget {
  final String dayOfWeek;
  final String formattedDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectedDateChanged;

  const CalendarAppBarTitle({
    super.key,
    required this.dayOfWeek,
    required this.formattedDate,
    required this.selectedDate,
    required this.onSelectedDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          final bool isLoading = state is EventLoading || state is EventInitial;
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Text(
                dayOfWeek,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: selectedDate.year,
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
                        onSelectedDateChanged(
                          DateTime(
                            value,
                            selectedDate.month,
                            selectedDate.day,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
