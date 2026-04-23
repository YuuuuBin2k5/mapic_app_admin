import 'package:flutter/material.dart';

import '../../data/models/user_profile_model.dart';

class UserList extends StatelessWidget {
  final List<UserProfileModel> users;
  final Function(UserProfileModel) onUserTap;
  final Function(UserProfileModel, String) onActionTap;

  const UserList({
    super.key,
    required this.users,
    required this.onUserTap,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserCard(
          user: user,
          onTap: () => onUserTap(user),
          onActionTap: (action) => onActionTap(user, action),
        );
      },
    );
  }
}

class UserCard extends StatelessWidget {
  final UserProfileModel user;
  final VoidCallback onTap;
  final Function(String) onActionTap;

  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getBorderColor(colorScheme),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      onBackgroundImageError: user.avatarUrl != null 
                          ? (exception, stackTrace) {} 
                          : null,
                      child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                          ? Text(
                              user.name.isNotEmpty 
                                  ? user.name[0].toUpperCase()
                                  : (user.username.isNotEmpty 
                                      ? user.username[0].toUpperCase()
                                      : '?'),
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // User info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusChip(colorScheme),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${user.username}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Risk indicator
                    _buildRiskIndicator(colorScheme),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats row
                Row(
                  children: [
                    _buildStatItem(
                      'Moments',
                      user.stats.momentsCount.toString(),
                      Icons.photo,
                      colorScheme,
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      'Bạn bè',
                      user.stats.friendsCount.toString(),
                      Icons.people,
                      colorScheme,
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      'Báo cáo',
                      user.stats.reportedCount.toString(),
                      Icons.report,
                      colorScheme,
                    ),
                    const Spacer(),
                    Text(
                      _formatDateTime(user.lastActiveAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Actions row
                Row(
                  children: [
                    if (user.lastLocation != null) ...[
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.lastLocation!.address ?? 'Không xác định',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else ...[
                      const Spacer(),
                    ],
                    if (user.status == UserStatus.active) ...[
                      _buildActionButton(
                        context,
                        'cảnh cáo',
                        Icons.warning,
                        Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        'khóa tạm thời',
                        Icons.pause,
                        Colors.red,
                      ),
                    ] else if (user.status == UserStatus.suspended || 
                               user.status == UserStatus.banned) ...[
                      _buildActionButton(
                        context,
                        'mở khóa',
                        Icons.lock_open,
                        Colors.green,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme) {
    Color backgroundColor;
    Color textColor;

    switch (user.status) {
      case UserStatus.active:
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        break;
      case UserStatus.warning:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange.shade700;
        break;
      case UserStatus.suspended:
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        break;
      case UserStatus.banned:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        break;
      case UserStatus.block:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            user.status.icon,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            user.status.displayName,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(ColorScheme colorScheme) {
    final riskScore = user.stats.riskScore;
    Color color;
    String label;

    if (riskScore >= 0.7) {
      color = Colors.red;
      label = 'Cao';
    } else if (riskScore >= 0.4) {
      color = Colors.orange;
      label = 'TB';
    } else {
      color = Colors.green;
      label = 'Thấp';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Rủi ro',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String action,
    IconData icon,
    Color color,
  ) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onActionTap(action),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                action,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(ColorScheme colorScheme) {
    switch (user.status) {
      case UserStatus.active:
        return colorScheme.primary.withOpacity(0.3);
      case UserStatus.warning:
        return Colors.orange.withOpacity(0.3);
      case UserStatus.suspended:
      case UserStatus.banned:
      case UserStatus.block:
        return colorScheme.error.withOpacity(0.3);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}p trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h trước';
    } else {
      return '${difference.inDays}d trước';
    }
  }
}