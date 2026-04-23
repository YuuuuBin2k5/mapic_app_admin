import 'package:flutter/material.dart';

import '../../data/models/notification_model.dart';

class NotificationFilters extends StatelessWidget {
  final NotificationType? typeFilter;
  final NotificationPriority? priorityFilter;
  final VoidCallback onClearFilters;

  const NotificationFilters({
    super.key,
    this.typeFilter,
    this.priorityFilter,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Bộ lọc đang áp dụng:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Xóa bộ lọc'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (typeFilter != null)
                Chip(
                  avatar: Text(typeFilter!.icon),
                  label: Text(typeFilter!.displayName),
                  backgroundColor: Color(typeFilter!.colorValue).withOpacity(0.1),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: onClearFilters,
                ),
              if (priorityFilter != null)
                Chip(
                  avatar: Text(priorityFilter!.icon),
                  label: Text(priorityFilter!.displayName),
                  backgroundColor: Color(priorityFilter!.colorValue).withOpacity(0.1),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: onClearFilters,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
