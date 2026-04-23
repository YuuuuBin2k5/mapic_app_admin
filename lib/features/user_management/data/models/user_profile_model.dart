import 'package:equatable/equatable.dart';

// Comprehensive User Status based on UI requirements
enum UserStatus { active, warning, suspended, banned, block }

class UserProfileModel extends Equatable {
  final String id;
  final String username;
  final String name;
  final String email;
  final String? phoneNumber; // Changed from phone to match UI
  final String? avatarUrl;
  final String? bio;
  final String? gender;
  final String? location;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final UserStatus status;
  final UserStats stats;
  final List<UserWarning> warnings;
  final List<UserReportHistoryItem> reportHistory; // Added for UI
  final List<String> linkedDeviceIds; // Added for UI
  final UserBan? currentBan;
  final UserLocation? lastLocation;
  final AdminData? adminData;

  const UserProfileModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.bio,
    this.gender,
    this.location,
    required this.createdAt,
    required this.lastActiveAt,
    required this.status,
    required this.stats,
    this.warnings = const [],
    this.reportHistory = const [],
    this.linkedDeviceIds = const [],
    this.currentBan,
    this.lastLocation,
    this.adminData,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Process avatar URL
    String? rawAvatarUrl = json['avatarUrl']?.toString();
    String? processedAvatarUrl;
    
    if (rawAvatarUrl != null && rawAvatarUrl.isNotEmpty) {
      if (rawAvatarUrl.startsWith('http://') || rawAvatarUrl.startsWith('https://')) {
        processedAvatarUrl = rawAvatarUrl;
      } else {
        processedAvatarUrl = 'http://localhost:8080/api/storage/avatars/$rawAvatarUrl';
      }
    }
    
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: (json['phoneNumber'] ?? json['phone'])?.toString(),
      avatarUrl: processedAvatarUrl,
      bio: json['bio']?.toString(),
      gender: json['gender']?.toString(),
      location: json['location']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : DateTime.now(),
      status: _parseStatus(json['status']?.toString()),
      stats: json['stats'] != null 
          ? UserStats.fromJson(json['stats'] as Map<String, dynamic>)
          : UserStats.fromAdminData(json['adminData'] != null 
              ? AdminData.fromJson(json['adminData'] as Map<String, dynamic>) 
              : null),
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => UserWarning.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reportHistory: (json['reportHistory'] as List<dynamic>?)
              ?.map((e) => UserReportHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      linkedDeviceIds: (json['linkedDeviceIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      currentBan: json['currentBan'] != null
          ? UserBan.fromJson(json['currentBan'] as Map<String, dynamic>)
          : (json['adminData']?['isBanned'] == true 
              ? UserBan.permanentDefault() 
              : null),
      lastLocation: json['lastLocation'] != null
          ? UserLocation.fromJson(json['lastLocation'] as Map<String, dynamic>)
          : null,
      adminData: json['adminData'] != null
          ? AdminData.fromJson(json['adminData'] as Map<String, dynamic>)
          : null,
    );
  }

  static UserStatus _parseStatus(String? status) {
    if (status == null) return UserStatus.active;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return UserStatus.active;
      case 'WARNING':
        return UserStatus.warning;
      case 'SUSPENDED':
        return UserStatus.suspended;
      case 'BANNED':
      case 'BLOCK':
        return UserStatus.banned;
      default:
        return UserStatus.active;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'gender': gender,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'status': status.name.toUpperCase(),
      'stats': stats.toJson(),
      'warnings': warnings.map((e) => e.toJson()).toList(),
      'reportHistory': reportHistory.map((e) => e.toJson()).toList(),
      'linkedDeviceIds': linkedDeviceIds,
      'currentBan': currentBan?.toJson(),
      'lastLocation': lastLocation?.toJson(),
      'adminData': adminData?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        username,
        name,
        email,
        phoneNumber,
        avatarUrl,
        bio,
        gender,
        location,
        createdAt,
        lastActiveAt,
        status,
        stats,
        warnings,
        reportHistory,
        linkedDeviceIds,
        currentBan,
        lastLocation,
        adminData,
      ];
}

class UserStats extends Equatable {
  final int momentsCount;
  final int friendsCount;
  final int commentsCount;
  final int reportedCount;
  final int reportsSubmitted;
  final double riskScore;

  const UserStats({
    this.momentsCount = 0,
    this.friendsCount = 0,
    this.commentsCount = 0,
    this.reportedCount = 0,
    this.reportsSubmitted = 0,
    this.riskScore = 0.0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      momentsCount: (json['momentsCount'] as num?)?.toInt() ?? 0,
      friendsCount: (json['friendsCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      reportedCount: (json['reportedCount'] as num?)?.toInt() ?? 0,
      reportsSubmitted: (json['reportsSubmitted'] as num?)?.toInt() ?? 0,
      riskScore: (json['riskScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory UserStats.fromAdminData(AdminData? adminData) {
    if (adminData == null) return const UserStats();
    return UserStats(
      momentsCount: adminData.totalMoments,
      friendsCount: adminData.totalFriends,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'momentsCount': momentsCount,
      'friendsCount': friendsCount,
      'commentsCount': commentsCount,
      'reportedCount': reportedCount,
      'reportsSubmitted': reportsSubmitted,
      'riskScore': riskScore,
    };
  }

  @override
  List<Object?> get props => [
        momentsCount,
        friendsCount,
        commentsCount,
        reportedCount,
        reportsSubmitted,
        riskScore,
      ];
}

class UserWarning extends Equatable {
  final String id;
  final String reason;
  final DateTime createdAt;

  const UserWarning({
    required this.id,
    required this.reason,
    required this.createdAt,
  });

  factory UserWarning.fromJson(Map<String, dynamic> json) {
    return UserWarning(
      id: json['id']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, reason, createdAt];
}

class UserReportHistoryItem extends Equatable {
  final String id;
  final String reason;
  final String status;
  final DateTime reportedAt;

  const UserReportHistoryItem({
    required this.id,
    required this.reason,
    required this.status,
    required this.reportedAt,
  });

  factory UserReportHistoryItem.fromJson(Map<String, dynamic> json) {
    return UserReportHistoryItem(
      id: json['id']?.toString() ?? '',
      reason: json['reason']?.toString() ?? 'Không rõ lý do',
      status: json['status']?.toString() ?? 'pending',
      reportedAt: json['reportedAt'] != null
          ? DateTime.parse(json['reportedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
      'status': status,
      'reportedAt': reportedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, reason, status, reportedAt];
}

enum BanType { temporary, permanent }

extension BanTypeExtension on BanType {
  String get displayName {
    switch (this) {
      case BanType.temporary:
        return 'Tạm thời';
      case BanType.permanent:
        return 'Vĩnh viễn';
    }
  }
}

class UserBan extends Equatable {
  final bool isActive;
  final BanType type;
  final String reason;
  final DateTime bannedAt;
  final DateTime? expiresAt;

  const UserBan({
    required this.isActive,
    required this.type,
    required this.reason,
    required this.bannedAt,
    this.expiresAt,
  });

  factory UserBan.fromJson(Map<String, dynamic> json) {
    return UserBan(
      isActive: json['isActive'] as bool? ?? false,
      type: json['type']?.toString().toLowerCase().contains('permanent') == true
          ? BanType.permanent
          : BanType.temporary,
      reason: json['reason']?.toString() ?? 'Không có lý do',
      bannedAt: json['bannedAt'] != null
          ? DateTime.parse(json['bannedAt'] as String)
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  factory UserBan.permanentDefault() {
    return UserBan(
      isActive: true,
      type: BanType.permanent,
      reason: 'Bị khóa bởi hệ thống',
      bannedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'type': type.name,
      'reason': reason,
      'bannedAt': bannedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [isActive, type, reason, bannedAt, expiresAt];
}

class UserLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  @override
  List<Object?> get props => [latitude, longitude, address];
}

// AdminData contains additional info for admin view
class AdminData extends Equatable {
  final int totalMoments;
  final int totalFriends;
  final bool isBanned;

  const AdminData({
    required this.totalMoments,
    required this.totalFriends,
    required this.isBanned,
  });

  factory AdminData.fromJson(Map<String, dynamic> json) {
    return AdminData(
      totalMoments: (json['totalMoments'] as num?)?.toInt() ?? 0,
      totalFriends: (json['totalFriends'] as num?)?.toInt() ?? 0,
      isBanned: json['isBanned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMoments': totalMoments,
      'totalFriends': totalFriends,
      'isBanned': isBanned,
    };
  }

  @override
  List<Object?> get props => [totalMoments, totalFriends, isBanned];
}

// User Activity Model (for getUserActivity endpoint)
class UserActivity extends Equatable {
  final List<ActivityItem> activities;
  final int totalCount;

  const UserActivity({
    required this.activities,
    required this.totalCount,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activities': activities.map((e) => e.toJson()).toList(),
      'totalCount': totalCount,
    };
  }

  @override
  List<Object?> get props => [activities, totalCount];
}

class ActivityItem extends Equatable {
  final String type;
  final String description;
  final DateTime timestamp;

  const ActivityItem({
    required this.type,
    required this.description,
    required this.timestamp,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [type, description, timestamp];
}

// Extensions for UI
extension UserStatusExtension on UserStatus {
  String get displayName {
    switch (this) {
      case UserStatus.active:
        return 'Hoạt động';
      case UserStatus.warning:
        return 'Cảnh cáo';
      case UserStatus.suspended:
        return 'Tạm khóa';
      case UserStatus.banned:
        return 'Bị khóa';
      case UserStatus.block:
        return 'Đã chặn';
    }
  }

  String get icon {
    switch (this) {
      case UserStatus.active:
        return '✅';
      case UserStatus.warning:
        return '⚠️';
      case UserStatus.suspended:
        return '⏳';
      case UserStatus.banned:
        return '🚫';
      case UserStatus.block:
        return '🔒';
    }
  }
}