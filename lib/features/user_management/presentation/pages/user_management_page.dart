import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/user_management_bloc.dart';
import '../widgets/user_list.dart';
import '../widgets/user_filters.dart';
import '../widgets/user_stats_cards.dart';
import 'user_detail_page.dart';
import '../../data/models/user_profile_model.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserManagementBloc()..add(LoadUsers()),
      child: const UserManagementView(),
    );
  }
}

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Người Dùng'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<UserManagementBloc>().add(LoadUsers());
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showAdvancedFilters(context);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _showExportDialog(context);
                  break;
                case 'bulk_actions':
                  _showBulkActionsDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Xuất dữ liệu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'bulk_actions',
                child: Row(
                  children: [
                    Icon(Icons.checklist),
                    SizedBox(width: 8),
                    Text('Hành động hàng loạt'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên, email, ID...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<UserManagementBloc>().add(
                          LoadUsers(searchQuery: ''),
                        );
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  onSubmitted: (query) {
                    context.read<UserManagementBloc>().add(
                      SearchUsers(query),
                    );
                  },
                ),
              ),
              // Tab bar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                onTap: (index) {
                  UserStatus? filterStatus;
                  switch (index) {
                    case 0:
                      filterStatus = null; // All
                      break;
                    case 1:
                      filterStatus = UserStatus.active;
                      break;
                    case 2:
                      filterStatus = UserStatus.warning;
                      break;
                    case 3:
                      filterStatus = UserStatus.suspended;
                      break;
                    case 4:
                      filterStatus = UserStatus.banned;
                      break;
                  }
                  context.read<UserManagementBloc>().add(
                    LoadUsers(statusFilter: filterStatus),
                  );
                },
                tabs: const [
                  Tab(text: 'Tất cả'),
                  Tab(text: 'Hoạt động'),
                  Tab(text: 'Cảnh cáo'),
                  Tab(text: 'Tạm khóa'),
                  Tab(text: 'Bị cấm'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<UserManagementBloc, UserManagementState>(
        listener: (context, state) {
          if (state is UserActionCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is UserManagementError) {
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
          return Column(
            children: [
              // Stats cards
              if (state is UsersLoaded) ...[
                UserStatsCards(
                  totalUsers: state.totalCount,
                  activeUsers: state.users.where((u) => u.status == UserStatus.active).length,
                  suspendedUsers: state.users.where((u) => u.status == UserStatus.suspended).length,
                  bannedUsers: state.users.where((u) => u.status == UserStatus.banned).length,
                ),
                const SizedBox(height: 8),
                // Filters
                UserFilters(
                  activeFilter: state.statusFilter,
                  onFilterChanged: (status, riskScore) {
                    context.read<UserManagementBloc>().add(
                      FilterUsers(status: status, minRiskScore: riskScore),
                    );
                  },
                ),
              ],
              // Content
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showUserActionsDialog(context);
        },
        icon: const Icon(Icons.admin_panel_settings),
        label: const Text('Hành động quản trị'),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserManagementState state) {
    if (state is UserManagementLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải danh sách người dùng...'),
          ],
        ),
      );
    }

    if (state is UsersLoaded) {
      if (state.users.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Không tìm thấy người dùng',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        );
      }

      return UserList(
        users: state.users,
        onUserTap: (user) {
          _showUserDetailsDialog(context, user);
        },
        onActionTap: (user, action) {
          _showActionConfirmationDialog(context, user, action);
        },
      );
    }

    if (state is UserManagementError) {
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
                context.read<UserManagementBloc>().add(LoadUsers());
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showUserDetailsDialog(BuildContext context, UserProfileModel user) {
    // Navigate to full user detail page instead of showing dialog
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserDetailPage(
          userId: user.id,
          initialUser: user,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showActionConfirmationDialog(
    BuildContext context,
    UserProfileModel user,
    String action,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Xác nhận $action'),
        content: Text(
          'Bạn có chắc chắn muốn $action người dùng ${user.username} không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Handle different actions
              switch (action) {
                case 'cảnh cáo':
                  context.read<UserManagementBloc>().add(
                    WarnUser(userId: user.id, reason: 'Vi phạm quy định'),
                  );
                  break;
                case 'khóa tạm thời':
                  context.read<UserManagementBloc>().add(
                    BanUser(
                      userId: user.id,
                      banType: BanType.temporary,
                      reason: 'Vi phạm quy định',
                      expiresAt: DateTime.now().add(const Duration(days: 7)),
                    ),
                  );
                  break;
                case 'khóa vĩnh viễn':
                  context.read<UserManagementBloc>().add(
                    BanUser(
                      userId: user.id,
                      banType: BanType.permanent,
                      reason: 'Vi phạm nghiêm trọng',
                    ),
                  );
                  break;
              }
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bộ lọc nâng cao'),
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

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xuất dữ liệu'),
        content: const Text('Chọn định dạng xuất dữ liệu:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang xuất dữ liệu CSV...')),
              );
            },
            child: const Text('CSV'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang xuất dữ liệu Excel...')),
              );
            },
            child: const Text('Excel'),
          ),
        ],
      ),
    );
  }

  void _showBulkActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hành động hàng loạt'),
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

  void _showUserActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hành động quản trị'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Gửi thông báo toàn hệ thống'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Tạo báo cáo người dùng'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Kiểm tra bảo mật'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}