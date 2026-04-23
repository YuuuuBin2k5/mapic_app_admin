import 'package:flutter/material.dart';

import '../../data/models/user_profile_model.dart';

class UserActionButtons extends StatelessWidget {
  final UserProfileModel user;
  final Function(String action, String? reason) onAction;

  const UserActionButtons({
    super.key,
    required this.user,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary actions row
        Row(
          children: [
            if (user.currentBan != null && user.currentBan!.isActive) ...[
              // User is banned - show unban button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showUnbanDialog(context),
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Mở khóa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else ...[
              // User is not banned - show ban options
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showBanDialog(context),
                  icon: const Icon(Icons.block),
                  label: const Text('Khóa TK'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showWarnDialog(context),
                  icon: const Icon(Icons.warning),
                  label: const Text('Cảnh cáo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Secondary actions row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showMessageDialog(context),
                icon: const Icon(Icons.message),
                label: const Text('Gửi tin nhắn'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showMoreActions(context),
                icon: const Icon(Icons.more_horiz),
                label: const Text('Thêm'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showBanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Khóa tài khoản'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Chọn loại khóa cho người dùng ${user.username}:'),
                const SizedBox(height: 16),
                
                // Ban options
                ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.orange),
                  title: const Text('Khóa tạm thời (7 ngày)'),
                  subtitle: const Text('Người dùng có thể truy cập lại sau 7 ngày'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _showReasonDialog(
                      context,
                      'Khóa tạm thời',
                      'ban_temporary',
                    );
                  },
                ),
                
                const Divider(),
                
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: const Text('Khóa vĩnh viễn'),
                  subtitle: const Text('Người dùng không thể truy cập lại'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _showReasonDialog(
                      context,
                      'Khóa vĩnh viễn',
                      'ban_permanent',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  void _showWarnDialog(BuildContext context) {
    _showReasonDialog(context, 'Cảnh cáo', 'warn');
  }

  void _showUnbanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mở khóa tài khoản'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bạn có chắc chắn muốn mở khóa tài khoản ${user.username}?'),
                const SizedBox(height: 16),
                if (user.currentBan != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin khóa hiện tại:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Loại: ${user.currentBan!.type.displayName}'),
                        Text('Lý do: ${user.currentBan!.reason}'),
                        Text('Ngày khóa: ${_formatDate(user.currentBan!.bannedAt)}'),
                        if (user.currentBan!.expiresAt != null)
                          Text('Hết hạn: ${_formatDate(user.currentBan!.expiresAt!)}'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onAction('unban', 'Mở khóa tài khoản');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mở khóa'),
          ),
        ],
      ),
    );
  }

  void _showReasonDialog(BuildContext context, String actionName, String actionType) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(actionName),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nhập lý do $actionName cho ${user.username}:'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Nhập lý do...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Quick reason buttons
                Wrap(
                  spacing: 8,
                  children: _getQuickReasons(actionType).map((reason) {
                    return ActionChip(
                      label: Text(reason),
                      onPressed: () {
                        reasonController.text = reason;
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập lý do')),
                );
                return;
              }
              Navigator.of(dialogContext).pop();
              onAction(actionType, reason);
            },
            child: Text(actionName),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(BuildContext context) {
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gửi tin nhắn'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Gửi tin nhắn đến ${user.username}:'),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final message = messageController.text.trim();
              if (message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập tin nhắn')),
                );
                return;
              }
              Navigator.of(dialogContext).pop();
              onAction('message', message);
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  void _showMoreActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hành động khác',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Xem báo cáo về user này'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.devices),
              title: const Text('Xem thiết bị liên kết'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Xuất dữ liệu user'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang xuất dữ liệu...')),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Lịch sử hành động admin'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getQuickReasons(String actionType) {
    switch (actionType) {
      case 'ban_temporary':
      case 'ban_permanent':
        return [
          'Spam nội dung',
          'Nội dung không phù hợp',
          'Quấy rối người khác',
          'Vi phạm quy định cộng đồng',
          'Tài khoản giả mạo',
        ];
      case 'warn':
        return [
          'Nội dung không phù hợp',
          'Ngôn ngữ không phù hợp',
          'Vi phạm nhẹ quy định',
          'Cảnh báo chung',
        ];
      default:
        return [];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}