import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final Widget Function(T) itemBuilder;
  final bool isExpanded;
  final bool wrapWithContainer;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
    this.isExpanded = false,
    this.wrapWithContainer = false,
  });

  @override
  Widget build(BuildContext context) {
    final dropdown = DropdownButton<T>(
      value: value,
      onChanged: (T? newValue) {
        if (newValue != null) onChanged(newValue);
      },
      isExpanded: isExpanded,
      alignment: Alignment.center,
      underline: Container(),
      dropdownColor: Theme.of(context).colorScheme.surface,
      style: Theme.of(context).textTheme.bodyMedium,
      items: items.map<DropdownMenuItem<T>>((T v) {
        return DropdownMenuItem<T>(
          value: v,
          child: itemBuilder(v),
        );
      }).toList(),
    );

    if (!wrapWithContainer) return dropdown;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: dropdown,
    );
  }
}
