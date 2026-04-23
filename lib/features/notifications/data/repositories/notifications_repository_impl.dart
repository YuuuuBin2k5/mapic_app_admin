import '../../../../shared/services/mapic_api_service.dart';
import '../models/notification_model.dart';

class NotificationsRepositoryImpl {
  final MapicApiService _apiService;

  NotificationsRepositoryImpl(this._apiService);

  Future<List<NotificationModel>> getNotifications({
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    int page = 0,
    int size = 20,
  }) async {
    try {
      // TODO: Replace with actual API call when backend is ready
      // final response = await _apiService.getNotifications(
      //   type: type,
      //   priority: priority,
      //   isRead: isRead,
      //   page: page,
      //   size: size,
      // );
      
      // For now, return mock data
      return _generateMockNotifications();
    } catch (e) {
      rethrow;
    }
  }

  Future<NotificationModel> getNotificationById(String id) async {
    try {
      // TODO: Replace with actual API call
      final notifications = await getNotifications();
      return notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // TODO: Replace with actual API call
      // await _apiService.markNotificationAsRead(notificationId);
      
      // Mock delay
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // TODO: Replace with actual API call
      // await _apiService.markAllNotificationsAsRead();
      
      // Mock delay
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      // TODO: Replace with actual API call
      // return await _apiService.getUnreadNotificationCount();
      
      final notifications = await getNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      // TODO: Replace with actual API call
      // await _apiService.deleteNotification(notificationId);
      
      // Mock delay
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      rethrow;
    }
  }

  // Mock data generator
  List<NotificationModel> _generateMockNotifications() {
    final now = DateTime.now();
    
    return [
      NotificationModel(
        id: '1',
        type: NotificationType.newReport,
        priority: NotificationPriority.critical,
        title: 'Báo cáo mới: Nội dung vi phạm',
        message: 'User @john_doe đã báo cáo moment của @target_user vì lý do spam và nội dung không phù hợp.',
        timestamp: now.subtract(const Duration(minutes: 2)),
        isRead: false,
        relatedUserId: 'user123',
        relatedReportId: 'report456',
      ),
      NotificationModel(
        id: '2',
        type: NotificationType.userBanned,
        priority: NotificationPriority.high,
        title: 'User bị khóa tự động',
        message: 'Hệ thống đã tự động khóa tài khoản @spam_user do vi phạm quy định nhiều lần.',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        relatedUserId: 'user789',
      ),
      NotificationModel(
        id: '3',
        type: NotificationType.systemAlert,
        priority: NotificationPriority.high,
        title: 'Cảnh báo: Tăng đột biến báo cáo',
        message: 'Số lượng báo cáo trong 1 giờ qua tăng 150% so với trung bình. Cần kiểm tra ngay.',
        timestamp: now.subtract(const Duration(minutes: 30)),
        isRead: false,
      ),
      NotificationModel(
        id: '4',
        type: NotificationType.dailyReport,
        priority: NotificationPriority.low,
        title: 'Báo cáo hàng ngày đã sẵn sàng',
        message: 'Báo cáo thống kê hoạt động ngày ${now.day}/${now.month}/${now.year} đã được tạo. Xem chi tiết tại dashboard.',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        type: NotificationType.userWarning,
        priority: NotificationPriority.medium,
        title: 'User nhận cảnh cáo',
        message: 'Admin @admin_user đã gửi cảnh cáo đến @warned_user vì đăng nội dung không phù hợp.',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
        relatedUserId: 'user456',
      ),
      NotificationModel(
        id: '6',
        type: NotificationType.contentDeleted,
        priority: NotificationPriority.medium,
        title: 'Nội dung bị xóa',
        message: 'Moment #12345 đã bị xóa do vi phạm quy định về nội dung bạo lực.',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
        relatedContentId: 'moment12345',
      ),
      NotificationModel(
        id: '7',
        type: NotificationType.contentApproved,
        priority: NotificationPriority.low,
        title: 'Nội dung được duyệt',
        message: 'Báo cáo #789 đã được xem xét và nội dung được xác nhận là hợp lệ.',
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
        relatedReportId: 'report789',
      ),
      NotificationModel(
        id: '8',
        type: NotificationType.userUnbanned,
        priority: NotificationPriority.medium,
        title: 'User được mở khóa',
        message: 'Tài khoản @unbanned_user đã được mở khóa sau khi hoàn thành thời gian khóa.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        relatedUserId: 'user999',
      ),
      NotificationModel(
        id: '9',
        type: NotificationType.newReport,
        priority: NotificationPriority.high,
        title: 'Báo cáo mới: Nội dung nhạy cảm',
        message: '3 users đã báo cáo cùng một moment vì chứa nội dung nhạy cảm.',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
        relatedReportId: 'report111',
      ),
      NotificationModel(
        id: '10',
        type: NotificationType.systemAlert,
        priority: NotificationPriority.critical,
        title: 'Cảnh báo: Lỗi hệ thống',
        message: 'Phát hiện lỗi trong quá trình xử lý ảnh. Đã tự động chuyển sang chế độ dự phòng.',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }
}
