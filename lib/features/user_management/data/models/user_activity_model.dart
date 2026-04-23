import 'package:equatable/equatable.dart';

enum ActivityType {
  login,
  logout,
  postMoment,
  addFriend,
  removeFriend,
  reportContent,
  receiveWarning,
  getBanned,
  getUnbanned,
  updateProfile,
  deleteContent,
}

class UserActivityModel extends Equatable {
  final String id;
  final ActivityType type;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String? relatedUserId;
  final String? relatedContentId;

  const UserActivityModel({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.metadata,
    this.relatedUserId,
    this.relatedContentId,
  });

  factory UserActivityModel.fromJson(Map<String, dynamic> json) {
    return UserActivityModel(
      id: json['id'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.login,
      ),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      relatedUserId: json['relatedUserId'] as String?,
      relatedContentId: json['relatedContentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'relatedUserId': relatedUserId,
      'relatedContentId': relatedContentId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        description,
        timestamp,
        metadata,
        relatedUserId,
        relatedContentId,
      ];
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.login:
        return 'Đăng nhập';
      case ActivityType.logout:
        return 'Đăng xuất';
      case ActivityType.postMoment:
        return 'Đăng moment';
      case ActivityType.addFriend:
        return 'Kết bạn';
      case ActivityType.removeFriend:
        return 'Hủy kết bạn';
      case ActivityType.reportContent:
        return 'Báo cáo nội dung';
      case ActivityType.receiveWarning:
        return 'Nhận cảnh cáo';
      case ActivityType.getBanned:
        return 'Bị khóa tài khoản';
      case ActivityType.getUnbanned:
        return 'Được mở khóa';
      case ActivityType.updateProfile:
        return 'Cập nhật hồ sơ';
      case ActivityType.deleteContent:
        return 'Xóa nội dung';
    }
  }

  String get icon {
    switch (this) {
      case ActivityType.login:
        return '🔓';
      case ActivityType.logout:
        return '🔒';
      case ActivityType.postMoment:
        return '📸';
      case ActivityType.addFriend:
        return '👥';
      case ActivityType.removeFriend:
        return '💔';
      case ActivityType.reportContent:
        return '🚨';
      case ActivityType.receiveWarning:
        return '⚠️';
      case ActivityType.getBanned:
        return '🚫';
      case ActivityType.getUnbanned:
        return '✅';
      case ActivityType.updateProfile:
        return '✏️';
      case ActivityType.deleteContent:
        return '🗑️';
    }
  }

  /// Get color for activity type
  int get colorValue {
    switch (this) {
      case ActivityType.login:
      case ActivityType.logout:
        return 0xFF2196F3; // Blue
      case ActivityType.postMoment:
      case ActivityType.updateProfile:
        return 0xFF4CAF50; // Green
      case ActivityType.addFriend:
        return 0xFF9C27B0; // Purple
      case ActivityType.removeFriend:
        return 0xFFFF9800; // Orange
      case ActivityType.reportContent:
      case ActivityType.receiveWarning:
        return 0xFFFFC107; // Amber
      case ActivityType.getBanned:
      case ActivityType.deleteContent:
        return 0xFFF44336; // Red
      case ActivityType.getUnbanned:
        return 0xFF4CAF50; // Green
    }
  }
}