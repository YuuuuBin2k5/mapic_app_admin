import 'package:equatable/equatable.dart';

// Backend only supports MOMENT, COMMENT, USER types
enum ReportType { moment, comment, userProfile }

// Comprehensive Report Status based on UI requirements
enum ReportStatus { pending, reviewed, resolved, dismissed }

// Comprehensive Report Reason based on UI requirements
// Backend only supports: FAKE_NEWS, INAPPROPRIATE, HATE_SPEECH, OTHER
enum ReportReason {
  fakeNews,
  inappropriate,
  hateSpeech,
  other,
  // Legacy values kept for backward compatibility but not used in filters
  spam,
  harassment,
  violence,
}

class ReportModel extends Equatable {
  final String id;
  final String reportedContentId;
  final ReportType type;
  final ReportReason reason;
  final String? reasonDetail;
  final DateTime createdAt;
  final ReportStatus status;
  
  // Nested objects from backend
  final ReporterInfo? reporter;
  final ReportedUserInfo? reportedUser;
  final ContentInfo? content;

  const ReportModel({
    required this.id,
    required this.reportedContentId,
    required this.type,
    required this.reason,
    this.reasonDetail,
    required this.createdAt,
    required this.status,
    this.reporter,
    this.reportedUser,
    this.content,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id']?.toString() ?? '',
      reportedContentId: json['reportedContentId']?.toString() ?? '',
      type: _parseType(json['contentType']?.toString()),
      reason: _parseReason(json['reasonCategory']?.toString()),
      reasonDetail: json['reason']?.toString(),
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
      status: _parseStatus(json['status']?.toString()),
      reporter: json['reporter'] != null 
        ? ReporterInfo.fromJson(json['reporter'] as Map<String, dynamic>)
        : null,
      reportedUser: json['reportedUser'] != null 
        ? ReportedUserInfo.fromJson(json['reportedUser'] as Map<String, dynamic>)
        : null,
      content: json['content'] != null 
        ? ContentInfo.fromJson(json['content'] as Map<String, dynamic>)
        : null,
    );
  }

  static ReportType _parseType(String? type) {
    if (type == null) return ReportType.moment;
    switch (type.toUpperCase()) {
      case 'MOMENT':
        return ReportType.moment;
      case 'COMMENT':
        return ReportType.comment;
      case 'USER':
        return ReportType.userProfile;
      default:
        return ReportType.moment;
    }
  }

  static ReportReason _parseReason(String? category) {
    if (category == null) return ReportReason.other;
    switch (category.toUpperCase()) {
      case 'SPAM':
        return ReportReason.spam;
      case 'HARASSMENT':
        return ReportReason.harassment;
      case 'INAPPROPRIATE':
        return ReportReason.inappropriate;
      case 'VIOLENCE':
        return ReportReason.violence;
      case 'FAKE_NEWS':
        return ReportReason.fakeNews;
      case 'HATE_SPEECH':
        return ReportReason.hateSpeech;
      default:
        return ReportReason.other;
    }
  }

  static ReportStatus _parseStatus(String? status) {
    if (status == null) return ReportStatus.pending;
    switch (status.toUpperCase()) {
      case 'PENDING':
        return ReportStatus.pending;
      case 'REVIEWED':
        return ReportStatus.reviewed;
      case 'RESOLVED':
        return ReportStatus.resolved;
      case 'DISMISSED':
        return ReportStatus.dismissed;
      default:
        return ReportStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportedContentId': reportedContentId,
      'contentType': type.name.toUpperCase(),
      'reason': reasonDetail ?? reason.name.toUpperCase(),
      'createdAt': createdAt.toIso8601String(),
      'status': status.name.toUpperCase(),
      'reporter': reporter?.toJson(),
      'reportedUser': reportedUser?.toJson(),
      'content': content?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    reportedContentId,
    type,
    reason,
    reasonDetail,
    createdAt,
    status,
    reporter,
    reportedUser,
    content,
  ];
  
  // Backward compatible getters for UI code
  int get reportCount => content?.reportCount ?? reportedUser?.totalReports ?? 1;
  String? get contentPreview => content?.content;
  String? get imageUrl => content?.mediaUrl;
  String get reporterUserId => reporter?.id ?? 'unknown';
  String get reportedUserId => reportedUser?.id ?? 'unknown';
}

// Nested classes matching backend structure
class ReporterInfo extends Equatable {
  final String id;
  final String username;
  final String name;
  final String? avatarUrl;

  const ReporterInfo({
    required this.id,
    required this.username,
    required this.name,
    this.avatarUrl,
  });

  factory ReporterInfo.fromJson(Map<String, dynamic> json) {
    String? rawAvatarUrl = json['avatarUrl']?.toString();
    String? processedAvatarUrl;
    
    if (rawAvatarUrl != null && rawAvatarUrl.isNotEmpty) {
      if (rawAvatarUrl.startsWith('http://') || rawAvatarUrl.startsWith('https://')) {
        processedAvatarUrl = rawAvatarUrl;
      } else {
        processedAvatarUrl = 'http://localhost:8080/api/storage/avatars/$rawAvatarUrl';
      }
    }
    
    return ReporterInfo(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatarUrl: processedAvatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }

  @override
  List<Object?> get props => [id, username, name, avatarUrl];
}

class ReportedUserInfo extends Equatable {
  final String id;
  final String username;
  final String name;
  final String? avatarUrl;
  final int totalReports;
  final bool isBanned;

  const ReportedUserInfo({
    required this.id,
    required this.username,
    required this.name,
    this.avatarUrl,
    required this.totalReports,
    required this.isBanned,
  });

  factory ReportedUserInfo.fromJson(Map<String, dynamic> json) {
    String? rawAvatarUrl = json['avatarUrl']?.toString();
    String? processedAvatarUrl;
    
    if (rawAvatarUrl != null && rawAvatarUrl.isNotEmpty) {
      if (rawAvatarUrl.startsWith('http://') || rawAvatarUrl.startsWith('https://')) {
        processedAvatarUrl = rawAvatarUrl;
      } else {
        processedAvatarUrl = 'http://localhost:8080/api/storage/avatars/$rawAvatarUrl';
      }
    }
    
    return ReportedUserInfo(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatarUrl: processedAvatarUrl,
      totalReports: (json['totalReports'] as num?)?.toInt() ?? 0,
      isBanned: json['isBanned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'avatarUrl': avatarUrl,
      'totalReports': totalReports,
      'isBanned': isBanned,
    };
  }

  @override
  List<Object?> get props => [id, username, name, avatarUrl, totalReports, isBanned];
}

class ContentInfo extends Equatable {
  final String id;
  final String type;
  final String content;
  final String? mediaUrl;
  final List<String>? mediaUrls;
  final DateTime createdAt;
  final bool isDeleted;
  final int reportCount;

  const ContentInfo({
    required this.id,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.mediaUrls,
    required this.createdAt,
    required this.isDeleted,
    this.reportCount = 0,
  });

  factory ContentInfo.fromJson(Map<String, dynamic> json) {
    // Get mediaUrl from JSON
    String? rawMediaUrl = json['mediaUrl']?.toString();
    
    // If mediaUrl doesn't start with http, it's a filename - prepend base URL
    String? processedMediaUrl;
    if (rawMediaUrl != null && rawMediaUrl.isNotEmpty) {
      if (rawMediaUrl.startsWith('http://') || rawMediaUrl.startsWith('https://')) {
        processedMediaUrl = rawMediaUrl;
      } else {
        // Assume it's a filename, construct full URL
        // This is a fallback in case backend doesn't return full URL
        processedMediaUrl = 'http://localhost:8080/api/storage/moments/$rawMediaUrl';
      }
    }
    
    return ContentInfo(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      mediaUrl: processedMediaUrl,
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)
          ?.map((e) {
            final url = e.toString();
            if (url.startsWith('http://') || url.startsWith('https://')) {
              return url;
            } else {
              return 'http://localhost:8080/api/storage/moments/$url';
            }
          })
          .toList(),
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
      isDeleted: json['isDeleted'] as bool? ?? false,
      reportCount: (json['reportCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'mediaUrl': mediaUrl,
      'mediaUrls': mediaUrls,
      'createdAt': createdAt.toIso8601String(),
      'isDeleted': isDeleted,
      'reportCount': reportCount,
    };
  }

  @override
  List<Object?> get props => [id, type, content, mediaUrl, createdAt, isDeleted];
}

// Helper extensions for UI
extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.moment:
        return 'Moment';
      case ReportType.comment:
        return 'Comment';
      case ReportType.userProfile:
        return 'User';
    }
  }

  String get icon {
    switch (this) {
      case ReportType.moment:
        return '📷';
      case ReportType.comment:
        return '💬';
      case ReportType.userProfile:
        return '👤';
    }
  }
}

extension ReportStatusExtension on ReportStatus {
  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Chờ xử lý';
      case ReportStatus.reviewed:
        return 'Đã xem';
      case ReportStatus.resolved:
        return 'Đã giải quyết';
      case ReportStatus.dismissed:
        return 'Đã bỏ qua';
    }
  }

  String get icon {
    switch (this) {
      case ReportStatus.pending:
        return '⏳';
      case ReportStatus.reviewed:
        return '👀';
      case ReportStatus.resolved:
        return '✅';
      case ReportStatus.dismissed:
        return '⏭️';
    }
  }
}

extension ReportReasonExtension on ReportReason {
  String get displayName {
    switch (this) {
      case ReportReason.fakeNews:
        return 'Nội dung sai lệch';
      case ReportReason.inappropriate:
        return 'Vi phạm tiêu chuẩn cộng đồng';
      case ReportReason.hateSpeech:
        return 'Ngôn từ thù ghét';
      case ReportReason.other:
        return 'Khác';
      // Legacy values
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Quấy rối';
      case ReportReason.violence:
        return 'Bạo lực';
    }
  }

  String get icon {
    switch (this) {
      case ReportReason.fakeNews:
        return '🎭';
      case ReportReason.inappropriate:
        return '🔞';
      case ReportReason.hateSpeech:
        return '🤬';
      case ReportReason.other:
        return '❓';
      // Legacy values
      case ReportReason.spam:
        return '📧';
      case ReportReason.harassment:
        return '🚫';
      case ReportReason.violence:
        return '👊';
    }
  }
}