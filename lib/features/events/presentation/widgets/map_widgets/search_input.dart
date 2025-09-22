import 'package:flutter/material.dart';
import 'package:schedule_event/l10n/app_localizations.dart';

class SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCleared;

  const SearchInput({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSubmitted,
    this.onChanged,
    this.onCleared,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchLocationHint,
          hintStyle:
              textTheme.bodyMedium?.copyWith(color: scheme.onSurface.withOpacity(0.6)),
          prefixIcon: isLoading
              ? Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                    ),
                  ),
                )
              : Icon(Icons.search, color: scheme.onSurfaceVariant),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: scheme.onSurfaceVariant),
                  onPressed: () {
                    controller.clear();
                    onCleared?.call();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: scheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      ),
    );
  }
}
