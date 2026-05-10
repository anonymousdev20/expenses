import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class TransactionFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const TransactionFilterChip({
    super.key,
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        labelStyle: AppTheme.captionStyle.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        deleteIcon: Icon(
          Icons.close,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        onDeleted: onDeleted,
      ),
    );
  }
}
