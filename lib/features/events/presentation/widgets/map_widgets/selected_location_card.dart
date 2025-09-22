import 'package:flutter/material.dart';
import 'package:schedule_event/l10n/app_localizations.dart';

class SelectedLocationCard extends StatelessWidget {
  final String address;
  final VoidCallback onConfirm;
  final bool enabled;

  const SelectedLocationCard({
    super.key,
    required this.address,
    required this.onConfirm,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Text(
    AppLocalizations.of(context)!.selectedLocation,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Theme.of(context)
          .textTheme
          .bodySmall
          ?.color
          ?.withOpacity(0.7),
        ),
      ),
          const SizedBox(height: 4),
          Text(
            address.isNotEmpty
                ? address
                : AppLocalizations.of(context)!.tapToSelectLocation,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: enabled && address.isNotEmpty ? onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.confirmLocation,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
