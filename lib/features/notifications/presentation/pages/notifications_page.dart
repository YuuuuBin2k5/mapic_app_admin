import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notifications_bloc.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_filters.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsBloc()..add(LoadNotifications()),
      child: const NotificationsView(),
    );
  }
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<NotificationsBloc>().add(RefreshNotifications());
            },
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              _showMarkAllAsReadDialog(context);
            },
            tooltip: 'Đánh dấu tất cả đã đọc',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'filter':
                  _showFilterDialog(context);
                  break;
                case 'settings':
                  _showNotificationSettings(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8),
                    Text('Bộ lọc'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Cài đặt'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 0) {
              // All notifications
              context.read<NotificationsBloc>().add(
                const FilterNotifications(isRead: null),
              );
            } else {
              // Unread only
              context.read<NotificationsBloc>().add(
                const FilterNotifications(isRead: false),
              );
            }
          },
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chưa đọc'),
          ],
        ),
      ),
      body: BlocConsumer<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          if (state is NotificationActionCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is NotificationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<NotificationsBloc>().add(RefreshNotifications());
              await Future.delayed(const Duration(seconds: 1));
            },
            child: _buildContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, NotificationsState state) {
    if (state is NotificationsLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải thông báo...'),
          ],
        ),
      );
    }

    if (state is NotificationsLoaded) {
      if (state.notifications.isEmpty) {
        return _buildEmptyState(context);
      }

      return Column(
        children: [
          // Summary bar
          _buildSummaryBar(context, state),
          
          // Filters (if any active)
          if (state.typeFilter != null || state.priorityFilter != null)
            NotificationFilters(
              typeFilter: state.typeFilter,
              priorityFilter: state.priorityFilter,
              onClearFilters: () {
                context.read<NotificationsBloc>().add(
                  const FilterNotifications(),
                );
              },
            ),
          
          // Notifications list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return NotificationCard(
                  notification: notification,
                  onTap: () => _handleNotificationTap(context, notification),
                  onMarkAsRead: () {
                    context.read<NotificationsBloc>().add(
                      MarkNotificationAsRead(notification.id),
                    );
                  },
                  onDelete: () {
                    _showDeleteConfirmation(context, notification);
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    if (state is NotificationsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<NotificationsBloc>().add(LoadNotifications());
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có thông báo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn sẽ nhận được thông báo về các sự kiện quan trọng ở đây',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context, NotificationsLoaded state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${state.notifications.length} thông báo',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (state.unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${state.unreadCount} chưa đọc',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Mark as read if unread
    if (!notification.isRead) {
      context.read<NotificationsBloc>().add(
        MarkNotificationAsRead(notification.id),
      );
    }

    // Navigate to related content
    if (notification.relatedReportId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chuyển đến báo cáo...')),
      );
      // TODO: Navigate to report detail
    } else if (notification.relatedUserId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chuyển đến user detail...')),
      );
      // TODO: Navigate to user detail
    } else if (notification.relatedContentId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chuyển đến nội dung...')),
      );
      // TODO: Navigate to content detail
    }
  }

  void _showMarkAllAsReadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đánh dấu tất cả đã đọc'),
        content: const Text(
          'Bạn có chắc chắn muốn đánh dấu tất cả thông báo là đã đọc?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<NotificationsBloc>().add(
                MarkAllNotificationsAsRead(),
              );
            },
            child: const Text('Đánh dấu tất cả'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    NotificationModel notification,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa thông báo'),
        content: const Text('Bạn có chắc chắn muốn xóa thông báo này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<NotificationsBloc>().add(
                DeleteNotification(notification.id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bộ lọc thông báo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lọc theo loại:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: NotificationType.values.map((type) {
                return FilterChip(
                  label: Text(type.displayName),
                  onSelected: (selected) {
                    Navigator.of(dialogContext).pop();
                    context.read<NotificationsBloc>().add(
                      FilterNotifications(type: selected ? type : null),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Lọc theo mức độ:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: NotificationPriority.values.map((priority) {
                return FilterChip(
                  label: Text(priority.displayName),
                  onSelected: (selected) {
                    Navigator.of(dialogContext).pop();
                    context.read<NotificationsBloc>().add(
                      FilterNotifications(priority: selected ? priority : null),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cài đặt thông báo'),
        content: const Text('Tính năng này sẽ được phát triển trong phiên bản tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
