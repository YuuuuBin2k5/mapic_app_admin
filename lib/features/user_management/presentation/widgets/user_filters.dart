import 'package:flutter/material.dart';

import '../../data/models/user_profile_model.dart';

class UserFilters extends StatelessWidget {
  final UserStatus? activeFilter;
  final Function(UserStatus?, double?) onFilterChanged;

  const UserFilters({
    super.key,
    this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Status filters
            _FilterChip(
              label: 'Hoạt động',
              isSelected: activeFilter == UserStatus.active,
              onTap: () {
                final newStatus = activeFilter == UserStatus.active 
                    ? null 
                    : UserStatus.active;
                onFilterChanged(newStatus, null);
              },
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Cảnh cáo',
              isSelected: activeFilter == UserStatus.warning,
              onTap: () {
                final newStatus = activeFilter == UserStatus.warning 
                    ? null 
                    : UserStatus.warning;
                onFilterChanged(newStatus, null);
              },
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Tạm khóa',
              isSelected: activeFilter == UserStatus.suspended,
              onTap: () {
                final newStatus = activeFilter == UserStatus.suspended 
                    ? null 
                    : UserStatus.suspended;
                onFilterChanged(newStatus, null);
              },
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Bị cấm',
              isSelected: activeFilter == UserStatus.banned,
              onTap: () {
                final newStatus = activeFilter == UserStatus.banned 
                    ? null 
                    : UserStatus.banned;
                onFilterChanged(newStatus, null);
              },
              color: Colors.red.shade700,
            ),
            const SizedBox(width: 8),
            // Risk score filters
            _FilterChip(
              label: 'Rủi ro cao',
              isSelected: false, // TODO: Implement risk filter state
              onTap: () {
                onFilterChanged(null, 0.7);
              },
              color: Colors.purple,
            ),
            const SizedBox(width: 8),
            // Clear filters
            _FilterChip(
              label: 'Xóa bộ lọc',
              isSelected: false,
              onTap: () {
                onFilterChanged(null, null);
              },
              color: Theme.of(context).colorScheme.outline,
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
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