import 'package:flutter/material.dart';

import '../../../../shared/services/auth_service.dart';
import '../../../auth/presentation/widgets/auth_wrapper.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSmallScreen;
  
  const DashboardAppBar({
    super.key,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      title: Row(
        children: [
          if (isSmallScreen) ...[
            Icon(
              Icons.admin_panel_settings,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            isSmallScreen ? 'MAPIC' : 'MAPIC Manager',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      actions: [
        // Notifications
        IconButton(
          icon: Stack(
            children: [
              Icon(
                Icons.notifications_outlined,
                size: isSmallScreen ? 20 : 24,
              ),
              // Notification badge
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 8 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            _showNotificationsBottomSheet(context);
          },
          tooltip: 'Thông báo',
        ),
        
        // User Menu
        PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: isSmallScreen ? 14 : 16,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: isSmallScreen ? 16 : 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
          tooltip: 'Menu người dùng',
          onSelected: (value) {
            switch (value) {
              case 'profile':
                _showProfileDialog(context);
                break;
              case 'settings':
                _showSettingsDialog(context);
                break;
              case 'logout':
                _showLogoutDialog(context);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: isSmallScreen ? 16 : 18),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Text(
                    'Hồ sơ',
                    style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: isSmallScreen ? 16 : 18),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Text(
                    'Cài đặt',
                    style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    size: isSmallScreen ? 16 : 18,
                    color: Colors.red,
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Text(
                    'Đăng xuất',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        SizedBox(width: isSmallScreen ? 4 : 8),
      ],
    );
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Thông báo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: 5,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: const Icon(Icons.info_outline, color: Colors.blue),
                  ),
                  title: Text('Thông báo ${index + 1}'),
                  subtitle: const Text('Nội dung thông báo mẫu'),
                  trailing: const Text('2 phút trước'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hồ sơ người dùng'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tên: Admin'),
            SizedBox(height: 8),
            Text('Email: admin@mapic.com'),
            SizedBox(height: 8),
            Text('Vai trò: Quản trị viên'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt'),
        content: const Text('Tính năng cài đặt đang được phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Perform logout
              final authService = AuthService();
              await authService.logout();
              
              // Navigate to login screen
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const AuthWrapper(),
                  ),
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}