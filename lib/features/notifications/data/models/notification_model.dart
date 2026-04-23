import 'package:equatable/equatable.dart';

enum NotificationType {
  newReport,
  userBanned,
  systemAlert,
  dailyReport,
  userWarning,
  contentDeleted,
  contentApproved,
  userUnbanned,
}

enum NotificationPriority {
  critical,
  high,
  medium,
  low,
}

class NotificationModel extends Equatable {
  final String id;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedUserId;
  final String? relatedContentId;
  final String? relatedReportId;
  final Map<String, dynamic>? metadata;
  final String? actionUrl;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.relatedUserId,
    this.relatedContentId,
    this.relatedReportId,
    this.metadata,
    this.actionUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.systemAlert,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      relatedUserId: json['relatedUserId'] as String?,
      relatedContentId: json['relatedContentId'] as String?,
      relatedReportId: json['relatedReportId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      actionUrl: json['actionUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'priority': priority.name,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'relatedUserId': relatedUserId,
      'relatedContentId': relatedContentId,
      'relatedReportId': relatedReportId,
      'metadata': metadata,
      'actionUrl': actionUrl,
    };
  }

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    NotificationPriority? priority,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? relatedUserId,
    String? relatedContentId,
    String? relatedReportId,
    Map<String, dynamic>? metadata,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedUserId: relatedUserId ?? this.relatedUserId,
      relatedContentId: relatedContentId ?? this.relatedContentId,
      relatedReportId: relatedReportId ?? this.relatedReportId,
      metadata: metadata ?? this.metadata,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        priority,
        title,
        message,
        timestamp,
        isRead,
        relatedUserId,
        relatedContentId,
        relatedReportId,
        metadata,
        actionUrl,
      ];
}

// Extensions for UI
extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.newReport:
        return 'Báo cáo mới';
      case NotificationType.userBanned:
        return 'User bị khóa';
      case NotificationType.systemAlert:
        return 'Cảnh báo hệ thống';
      case NotificationType.dailyReport:
        return 'Báo cáo định kỳ';
      case NotificationType.userWarning:
        return 'User bị cảnh cáo';
      case NotificationType.contentDeleted:
        return 'Nội dung bị xóa';
      case NotificationType.contentApproved:
        return 'Nội dung được duyệt';
      case NotificationType.userUnbanned:
        return 'User được mở khóa';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.newReport:
        return '🚨';
      case NotificationType.userBanned:
        return '🚫';
      case NotificationType.systemAlert:
        return '⚠️';
      case NotificationType.dailyReport:
        return '📊';
      case NotificationType.userWarning:
        return '⚠️';
      case NotificationType.contentDeleted:
        return '🗑️';
      case NotificationType.contentApproved:
        return '✅';
      case NotificationType.userUnbanned:
        return '🔓';
    }
  }

  int get colorValue {
    switch (this) {
      case NotificationType.newReport:
      case NotificationType.userBanned:
        return 0xFFF44336; // Red
      case NotificationType.systemAlert:
      case NotificationType.userWarning:
        return 0xFFFF9800; // Orange
      case NotificationType.dailyReport:
        return 0xFF2196F3; // Blue
      case NotificationType.contentDeleted:
        return 0xFF9E9E9E; // Gray
      case NotificationType.contentApproved:
      case NotificationType.userUnbanned:
        return 0xFF4CAF50; // Green
    }
  }
}

extension NotificationPriorityExtension on NotificationPriority {
  String get displayName {
    switch (this) {
      case NotificationPriority.critical:
        return 'KHẨN CẤP';
      case NotificationPriority.high:
        return 'CAO';
      case NotificationPriority.medium:
        return 'TRUNG BÌNH';
      case NotificationPriority.low:
        return 'THẤP';
    }
  }

  String get icon {
    switch (this) {
      case NotificationPriority.critical:
        return '🔴';
      case NotificationPriority.high:
        return '🟠';
      case NotificationPriority.medium:
        return '🟡';
      case NotificationPriority.low:
        return '🔵';
    }
  }

  int get colorValue {
    switch (this) {
      case NotificationPriority.critical:
        return 0xFFF44336; // Red
      case NotificationPriority.high:
        return 0xFFFF9800; // Orange
      case NotificationPriority.medium:
        return 0xFFFFC107; // Amber
      case NotificationPriority.low:
        return 0xFF2196F3; // Blue
    }
  }
}
