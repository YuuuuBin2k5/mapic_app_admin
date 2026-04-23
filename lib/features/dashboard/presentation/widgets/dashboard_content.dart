import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/services/auth_service.dart';
import '../../../auth/presentation/widgets/auth_wrapper.dart';
import '../../../content_moderation/presentation/pages/content_moderation_page.dart';
import '../../../user_management/presentation/pages/user_management_page.dart';
import '../pages/analytics_page.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 24),
          _buildQuickStats(context, isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 24),
          _buildFeaturesSection(context, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MAPIC Manager',
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Quản lý và giám sát hệ thống MAPIC',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
            fontSize: isSmallScreen ? 13 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, bool isSmallScreen) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        // Handle error state - especially 403 Forbidden
        if (state is DashboardError) {
          // Check if it's an authentication error
          if (state.message.contains('403') || 
              state.message.contains('Forbidden') ||
              state.message.contains('Unauthorized')) {
            // Clear auth and redirect to login
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final authService = AuthService();
              await authService.logout();
              
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const AuthWrapper(),
                  ),
                  (route) => false,
                );
              }
            });
            
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Phiên đăng nhập đã hết hạn. Đang chuyển về trang đăng nhập...',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          
          // Other errors
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Lỗi tải dữ liệu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<DashboardBloc>().add(const RefreshDashboardData());
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Resolve display values
        String totalUsers = '—';
        String pendingReports = '—';
        String totalMoments = '—';
        String userTrend = '';
        String reportTrend = '';
        String momentTrend = '';

        if (state is DashboardLoaded) {
          totalUsers = _formatNumber(state.totalUsers);
          pendingReports = state.pendingReports.toString();
          totalMoments = _formatNumber(state.totalMoments);
          userTrend = 'Đang hoạt động: ${_formatNumber(state.activeUsers)}';
          reportTrend = 'Đã xử lý hôm nay: ${state.resolvedReportsToday}';
          momentTrend = 'Hôm nay: ${state.momentsToday}';
        } else if (state is DashboardLoading) {
          totalUsers = '...';
          pendingReports = '...';
          totalMoments = '...';
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 500 ? 3 : 1;

            final cards = [
              _QuickStatCard(
                title: 'Tổng người dùng',
                value: totalUsers,
                trend: userTrend,
                icon: Icons.people,
                color: Colors.blue,
                isSmallScreen: isSmallScreen,
              ),
              _QuickStatCard(
                title: 'Báo cáo chờ xử lý',
                value: pendingReports,
                trend: reportTrend,
                icon: Icons.report_problem,
                color: Colors.orange,
                isSmallScreen: isSmallScreen,
              ),
              _QuickStatCard(
                title: 'Tổng Moments',
                value: totalMoments,
                trend: momentTrend,
                icon: Icons.photo_library,
                color: Colors.purple,
                isSmallScreen: isSmallScreen,
              ),
            ];

            if (crossAxisCount == 1) {
              return Column(
                children: [
                  cards[0],
                  const SizedBox(height: 8),
                  cards[1],
                  const SizedBox(height: 8),
                  cards[2],
                ],
              );
            }

            // Use Wrap instead of GridView for better height handling
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cards.map((card) {
                return SizedBox(
                  width: (constraints.maxWidth - 16) / 3,
                  child: card,
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }


  Widget _buildFeaturesSection(BuildContext context, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tính năng chính',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout for features
            final crossAxisCount = constraints.maxWidth > 500 ? 2 : 1;
            
            final features = [
              _FeatureCard(
                title: 'Kiểm Duyệt Nội Dung',
                subtitle: 'Quản lý báo cáo',
                icon: Icons.gavel,
                color: Colors.purple,
                isSmallScreen: isSmallScreen,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ContentModerationPage(),
                    ),
                  );
                },
              ),
              _FeatureCard(
                title: 'Quản Lý Người Dùng',
                subtitle: 'Hồ sơ và hệ thống ban',
                icon: Icons.manage_accounts,
                color: Colors.indigo,
                isSmallScreen: isSmallScreen,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const UserManagementPage(),
                    ),
                  );
                },
              ),
              _FeatureCard(
                title: 'Phân Tích & Báo Cáo',
                subtitle: 'Thống kê và insights',
                icon: Icons.analytics,
                color: Colors.green,
                isSmallScreen: isSmallScreen,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AnalyticsPage(),
                    ),
                  );
                },
              ),
            ];

            if (crossAxisCount == 1) {
              // Single column layout for small screens
              return Column(
                children: [
                  features[0],
                  const SizedBox(height: 12),
                  features[1],
                  const SizedBox(height: 12),
                  features[2],
                ],
              );
            } else {
              // Two column layout for larger screens
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: features[0],
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: features[1],
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: features[2],
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;
  final bool isSmallScreen;

  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: isSmallScreen ? 18 : 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (trend.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    trend,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 10 : 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSmallScreen;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSmallScreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: isSmallScreen 
            ? _buildHorizontalLayout(context)
            : _buildVerticalLayout(context),
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: color,
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: color,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}