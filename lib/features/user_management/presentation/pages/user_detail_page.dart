import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/user_management_bloc.dart';
import '../widgets/user_profile_header.dart';
import '../widgets/user_statistics_section.dart';
import '../widgets/user_activity_timeline.dart';
import '../widgets/user_action_buttons.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/user_activity_model.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;
  final UserProfileModel? initialUser;

  const UserDetailPage({
    super.key,
    required this.userId,
    this.initialUser,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserManagementBloc()..add(LoadUserDetails(userId)),
      child: UserDetailView(initialUser: initialUser),
    );
  }
}

class UserDetailView extends StatefulWidget {
  final UserProfileModel? initialUser;

  const UserDetailView({super.key, this.initialUser});

  @override
  State<UserDetailView> createState() => _UserDetailViewState();
}

class _UserDetailViewState extends State<UserDetailView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Reload user details after action
            context.read<UserManagementBloc>().add(LoadUserDetails(state.userId));
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
          if (state is UserManagementLoading && widget.initialUser == null) {
            return _buildLoadingState();
          }

          if (state is UserDetailsLoaded) {
            return _buildDetailContent(context, state.user, state.additionalData);
          }

          if (widget.initialUser != null) {
            return _buildDetailContent(context, widget.initialUser!, null);
          }

          if (state is UserManagementError) {
            return _buildErrorState(context, state.message);
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải thông tin người dùng...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
      ),
      body: Center(
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
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<UserManagementBloc>().add(LoadUserDetails(widget.initialUser?.id ?? ''));
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    UserProfileModel user,
    Map<String, dynamic>? additionalData,
  ) {
    // Parse activities from additional data
    List<UserActivityModel> activities = [];
    if (additionalData != null && additionalData['activities'] != null) {
      activities = (additionalData['activities'] as List<dynamic>)
          .map((e) => UserActivityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // Generate mock activities for demo
      activities = _generateMockActivities(user);
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: UserProfileHeader(user: user),
            ),
            title: Text(user.username),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<UserManagementBloc>().add(LoadUserDetails(user.id));
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'export':
                      _exportUserData(context, user);
                      break;
                    case 'history':
                      _showActionHistory(context, user);
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
                    value: 'history',
                    child: Row(
                      children: [
                        Icon(Icons.history),
                        SizedBox(width: 8),
                        Text('Lịch sử hành động'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ];
      },
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Tổng quan', icon: Icon(Icons.dashboard, size: 20)),
                Tab(text: 'Hoạt động', icon: Icon(Icons.timeline, size: 20)),
                Tab(text: 'Báo cáo', icon: Icon(Icons.report, size: 20)),
                Tab(text: 'Bạn bè', icon: Icon(Icons.people, size: 20)),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview tab
                _buildOverviewTab(context, user),
                // Activity tab
                _buildActivityTab(context, activities),
                // Reports tab
                _buildReportsTab(context, user),
                // Friends tab
                _buildFriendsTab(context, user),
              ],
            ),
          ),
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: UserActionButtons(
              user: user,
              onAction: (action, reason) {
                _handleUserAction(context, user, action, reason);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, UserProfileModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserStatisticsSection(user: user),
          const SizedBox(height: 24),
          _buildInfoSection(context, user),
          const SizedBox(height: 24),
          _buildSecuritySection(context, user),
        ],
      ),
    );
  }

  Widget _buildActivityTab(BuildContext context, List<UserActivityModel> activities) {
    return UserActivityTimeline(activities: activities);
  }

  Widget _buildReportsTab(BuildContext context, UserProfileModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lịch sử báo cáo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (user.reportHistory.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.report_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có báo cáo nào',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: user.reportHistory.length,
              itemBuilder: (context, index) {
                final report = user.reportHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                      child: Icon(
                        Icons.report,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    title: Text(report.reason),
                    subtitle: Text(_formatDateTime(report.reportedAt)),
                    trailing: Chip(
                      label: Text(report.status),
                      backgroundColor: _getStatusColor(report.status),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab(BuildContext context, UserProfileModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin bạn bè',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Tổng số bạn bè: ${user.stats.friendsCount}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng đang phát triển')),
                      );
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('Xem danh sách bạn bè'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, UserProfileModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin cá nhân',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Email', user.email),
            if (user.phoneNumber != null)
              _buildInfoRow(context, 'Số điện thoại', user.phoneNumber!),
            _buildInfoRow(context, 'Ngày tham gia', _formatDate(user.createdAt)),
            _buildInfoRow(context, 'Hoạt động cuối', _formatDateTime(user.lastActiveAt)),
            if (user.lastLocation != null)
              _buildInfoRow(context, 'Vị trí cuối', user.lastLocation!.address ?? 'Không xác định'),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context, UserProfileModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bảo mật & Rủi ro',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: _getRiskColor(user.stats.riskScore),
                ),
                const SizedBox(width: 8),
                Text('Điểm rủi ro: ${(user.stats.riskScore * 10).toStringAsFixed(1)}/10'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRiskColor(user.stats.riskScore).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRiskLevel(user.stats.riskScore),
                    style: TextStyle(
                      color: _getRiskColor(user.stats.riskScore),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: user.stats.riskScore,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(_getRiskColor(user.stats.riskScore)),
            ),
            const SizedBox(height: 16),
            if (user.linkedDeviceIds.isNotEmpty) ...[
              Text('Thiết bị liên kết: ${user.linkedDeviceIds.length}'),
              const SizedBox(height: 8),
            ],
            if (user.warnings.isNotEmpty) ...[
              Text('Cảnh cáo: ${user.warnings.length}'),
              const SizedBox(height: 8),
            ],
            if (user.currentBan != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đang bị khóa: ${user.currentBan!.type.displayName}',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Lý do: ${user.currentBan!.reason}',
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                          if (user.currentBan!.expiresAt != null)
                            Text(
                              'Hết hạn: ${_formatDateTime(user.currentBan!.expiresAt!)}',
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(
    BuildContext context,
    UserProfileModel user,
    String action,
    String? reason,
  ) {
    switch (action) {
      case 'ban_temporary':
        context.read<UserManagementBloc>().add(
          BanUser(
            userId: user.id,
            banType: BanType.temporary,
            reason: reason ?? 'Vi phạm quy định',
            expiresAt: DateTime.now().add(const Duration(days: 7)),
          ),
        );
        break;
      case 'ban_permanent':
        context.read<UserManagementBloc>().add(
          BanUser(
            userId: user.id,
            banType: BanType.permanent,
            reason: reason ?? 'Vi phạm nghiêm trọng',
          ),
        );
        break;
      case 'warn':
        context.read<UserManagementBloc>().add(
          WarnUser(
            userId: user.id,
            reason: reason ?? 'Cảnh cáo vi phạm',
          ),
        );
        break;
      case 'unban':
        context.read<UserManagementBloc>().add(
          UnbanUser(
            userId: user.id,
            reason: reason ?? 'Mở khóa tài khoản',
          ),
        );
        break;
      case 'message':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tính năng gửi tin nhắn đang phát triển')),
        );
        break;
    }
  }

  void _exportUserData(BuildContext context, UserProfileModel user) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang xuất dữ liệu người dùng...')),
    );
  }

  void _showActionHistory(BuildContext context, UserProfileModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lịch sử hành động'),
        content: const Text('Tính năng này sẽ được phát triển trong phiên bản tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  List<UserActivityModel> _generateMockActivities(UserProfileModel user) {
    final now = DateTime.now();
    return [
      UserActivityModel(
        id: '1',
        type: ActivityType.login,
        description: 'Đăng nhập từ thiết bị di động',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      UserActivityModel(
        id: '2',
        type: ActivityType.postMoment,
        description: 'Đăng moment mới tại Hà Nội',
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      UserActivityModel(
        id: '3',
        type: ActivityType.addFriend,
        description: 'Kết bạn với người dùng khác',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      UserActivityModel(
        id: '4',
        type: ActivityType.updateProfile,
        description: 'Cập nhật ảnh đại diện',
        timestamp: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  Color _getRiskColor(double riskScore) {
    if (riskScore >= 0.7) return Colors.red;
    if (riskScore >= 0.4) return Colors.orange;
    if (riskScore >= 0.2) return Colors.amber;
    return Colors.green;
  }

  String _getRiskLevel(double riskScore) {
    if (riskScore >= 0.7) return 'CAO';
    if (riskScore >= 0.4) return 'TRUNG BÌNH';
    if (riskScore >= 0.2) return 'THẤP';
    return 'AN TOÀN';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green.shade100;
      case 'pending':
        return Colors.orange.shade100;
      case 'dismissed':
        return Colors.grey.shade100;
      default:
        return Colors.blue.shade100;
    }
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