import 'package:flutter/material.dart';

import '../../data/models/report_model.dart';

class ModerationFilters extends StatelessWidget {
  final ReportType? activeFilter;
  final ReportStatus? statusFilter;
  final Function(ReportType?, ReportStatus?, ReportReason?) onFilterChanged;

  const ModerationFilters({
    super.key,
    this.activeFilter,
    this.statusFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Only show the 4 main categories that backend supports
    final mainReasons = [
      ReportReason.fakeNews,
      ReportReason.inappropriate,
      ReportReason.hateSpeech,
      ReportReason.other,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Status filters
            _FilterChip(
              label: 'Chờ xử lý',
              isSelected: statusFilter == ReportStatus.pending,
              onTap: () {
                final newStatus = statusFilter == ReportStatus.pending 
                    ? null 
                    : ReportStatus.pending;
                onFilterChanged(activeFilter, newStatus, null);
              },
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Đã xem',
              isSelected: statusFilter == ReportStatus.reviewed,
              onTap: () {
                final newStatus = statusFilter == ReportStatus.reviewed 
                    ? null 
                    : ReportStatus.reviewed;
                onFilterChanged(activeFilter, newStatus, null);
              },
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            // Reason filters - only show main 4 categories
            ...mainReasons.map((reason) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: '${reason.icon} ${reason.displayName}',
                isSelected: false, // TODO: Implement reason filter state
                onTap: () {
                  onFilterChanged(activeFilter, statusFilter, reason);
                },
                color: _getReasonColor(context, reason),
              ),
            )),
            const SizedBox(width: 8),
            // Clear filters
            _FilterChip(
              label: 'Xóa bộ lọc',
              isSelected: false,
              onTap: () {
                onFilterChanged(null, null, null);
              },
              color: Theme.of(context).colorScheme.outline,
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Color _getReasonColor(BuildContext context, ReportReason reason) {
    switch (reason) {
      case ReportReason.fakeNews:
        return Colors.purple;
      case ReportReason.inappropriate:
        return Theme.of(context).colorScheme.error;
      case ReportReason.hateSpeech:
        return Colors.red.shade700;
      case ReportReason.other:
        return Theme.of(context).colorScheme.outline;
      // Legacy values
      case ReportReason.spam:
        return Colors.orange;
      case ReportReason.harassment:
        return Colors.red.shade700;
      case ReportReason.violence:
        return Theme.of(context).colorScheme.error;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final bool isOutlined;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: isSelected 
          ? color 
          : isOutlined 
              ? Colors.transparent 
              : color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: isOutlined 
                ? Border.all(color: color, width: 1)
                : null,
          ),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected 
                  ? theme.colorScheme.onPrimary 
                  : color,
              fontWeight: isSelected 
                  ? FontWeight.bold 
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}