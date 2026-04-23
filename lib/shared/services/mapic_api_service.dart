import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../features/content_moderation/data/models/report_model.dart';
import '../../features/content_moderation/data/models/moderation_action_model.dart';
import '../../features/user_management/data/models/user_profile_model.dart';

class MapicApiService {
  late final Dio _dio;
  final Logger _logger = Logger();

  MapicApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Read token from SharedPreferences on every request
        final token = await _getAuthToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) async {
        _logger.e('API Error [${error.response?.statusCode}]: ${error.message}');
        
        // Handle 401 Unauthorized - token expired or invalid
        if (error.response?.statusCode == 401) {
          _logger.w('Unauthorized access - clearing auth and redirecting to login');
          
          // Clear stored tokens
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          await prefs.remove('refresh_token');
          
          // Note: Navigation should be handled by the UI layer
          // The error will propagate and UI can catch it to redirect
        }
        
        handler.next(error);
      },
    ));
  }

  /// Reads JWT token from SharedPreferences (set after admin login)
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      _logger.w('Could not read auth token: $e');
      return null;
    }
  }

  // ==================== AUTH APIs ====================

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.authLogin,
        data: {
          'username': username,
          'password': password,
        },
      );
      final data = response.data;
      return data['data'] ?? data;
    } catch (e) {
      _logger.e('Error logging in: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.authLogout);
    } catch (e) {
      _logger.e('Error logging out: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.authRefresh,
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );
      final data = response.data;
      return data['data'] ?? data;
    } catch (e) {
      _logger.e('Error refreshing token: $e');
      rethrow;
    }
  }

  // ==================== DASHBOARD APIs ====================

  Future<Map<String, dynamic>> getDashboardMetrics() async {
    try {
      final response = await _dio.get(ApiConstants.dashboardMetrics);
      final data = response.data;
      // Backend returns ApiResponse<Map<String, Object>> with structure: {success, message, data}
      // We need to extract the 'data' field which contains the actual metrics
      final metricsData = data['data'] ?? data;
      return metricsData is Map ? Map<String, dynamic>.from(metricsData) : {};
    } catch (e) {
      _logger.e('Error getting dashboard metrics: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDashboardTrends() async {
    try {
      final response = await _dio.get(ApiConstants.dashboardTrends);
      final data = response.data;
      final trendsData = data['data'] ?? data;
      return trendsData is Map ? Map<String, dynamic>.from(trendsData) : {};
    } catch (e) {
      _logger.e('Error getting dashboard trends: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTrendData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.dashboardMetrics}/trends',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      final data = response.data;
      final List<dynamic> trendsJson = data['data'] ?? data;
      return trendsJson.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      _logger.e('Error getting trend data: $e');
      rethrow;
    }
  }

  // ==================== USER MANAGEMENT APIs (70% Implementation) ====================
  // Backend only supports: getUsers, getUserById, updateUserStatus, getUserActivity, searchUsers
  // NOT supported: ban/unban/warn (no entities for these)

  Future<Map<String, dynamic>> getUsers({
    int page = 0,
    int size = 20,
    String? search,
    UserStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (status != null) {
        queryParams['status'] = status.name.toUpperCase();
      }

      final response = await _dio.get(
        ApiConstants.users,
        queryParameters: queryParams,
      );

      // Backend returns ApiResponse<Page<UserProfileResponse>>
      final data = response.data;
      final pageData = data['data'] ?? data;
      return {
        'content': (pageData['content'] as List<dynamic>?)
                ?.map((json) => UserProfileModel.fromJson(json as Map<String, dynamic>))
                .toList() ??
            [],
        'totalElements': (pageData['totalElements'] as num?)?.toInt() ?? 0,
        'totalPages': (pageData['totalPages'] as num?)?.toInt() ?? 0,
        'pageNumber': (pageData['pageNumber'] as num?)?.toInt() ?? 0,
        'pageSize': (pageData['pageSize'] as num?)?.toInt() ?? size,
      };
    } catch (e) {
      _logger.e('Error getting users: $e');
      rethrow;
    }
  }

  Future<UserProfileModel> getUserById(String userId) async {
    try {
      final response = await _dio.get(
        ApiConstants.userById.replaceAll('{id}', userId),
      );
      final data = response.data;
      final userData = data['data'] ?? data;
      return UserProfileModel.fromJson(userData as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error getting user by ID: $e');
      rethrow;
    }
  }

  Future<void> updateUserStatus(
    String userId,
    UserStatus status,
  ) async {
    try {
      await _dio.put(
        ApiConstants.userStatus.replaceAll('{id}', userId),
        data: {
          'status': status.name.toUpperCase(),
        },
      );
    } catch (e) {
      _logger.e('Error updating user status: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserActivity(String userId, {int days = 7}) async {
    try {
      final response = await _dio.get(
        ApiConstants.userActivity.replaceAll('{id}', userId),
        queryParameters: {'days': days},
      );
      final data = response.data;
      return data['data'] ?? data;
    } catch (e) {
      _logger.e('Error getting user activity: $e');
      rethrow;
    }
  }

  Future<List<UserProfileModel>> searchUsers(String query, {int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        ApiConstants.userSearch,
        queryParameters: {
          'query': query,
          'page': page,
          'size': size,
        },
      );
      final data = response.data;
      final pageData = data['data'] ?? data;
      final List<dynamic> usersJson = pageData['content'] ?? [];
      return usersJson
          .map((json) => UserProfileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error searching users: $e');
      rethrow;
    }
  }

  // ==================== CONTENT MODERATION APIs (70% Implementation) ====================
  // Backend supports: getReportQueue, getReportDetails, moderateContent, approveContent, rejectContent, getStatistics
  // Actions: DELETE (moments), HIDE (moments only), APPROVE, IGNORE
  // Note: Comments can only be DELETED, not HIDDEN (no status field)

  Future<Map<String, dynamic>> getReportQueue({
    ReportType? type,
    ReportStatus? status,
    ReportReason? reason,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (type != null) queryParams['type'] = type.name.toUpperCase();
      if (status != null) queryParams['status'] = status.name.toUpperCase();
      if (reason != null) queryParams['reason'] = reason.name.toUpperCase();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        ApiConstants.contentQueue,
        queryParameters: queryParams,
      );

      final data = response.data;
      final pageData = data['data'] ?? data;
      return {
        'content': (pageData['content'] as List<dynamic>?)
                ?.map((json) => ReportModel.fromJson(json as Map<String, dynamic>))
                .toList() ??
            [],
        'totalElements': (pageData['totalElements'] as num?)?.toInt() ?? 0,
        'totalPages': (pageData['totalPages'] as num?)?.toInt() ?? 0,
        'pageNumber': (pageData['pageNumber'] as num?)?.toInt() ?? 0,
        'pageSize': (pageData['pageSize'] as num?)?.toInt() ?? size,
      };
    } catch (e) {
      _logger.e('Error getting report queue: $e');
      rethrow;
    }
  }

  Future<ReportModel> getReportDetails(String reportId) async {
    try {
      final response = await _dio.get(
        ApiConstants.contentReportDetails.replaceAll('{id}', reportId),
      );
      final data = response.data;
      final reportData = data['data'] ?? data;
      return ReportModel.fromJson(reportData as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error getting report details: $e');
      rethrow;
    }
  }

  Future<void> moderateContent(
    String reportId,
    ModerationAction action, {
    String? reason,
    String? note,
  }) async {
    try {
      await _dio.post(
        ApiConstants.contentModerate.replaceAll('{id}', reportId),
        data: {
          'action': action.name.toUpperCase(),
          if (reason != null) 'reason': reason,
          if (note != null) 'note': note,
        },
      );
    } catch (e) {
      _logger.e('Error moderating content: $e');
      rethrow;
    }
  }

  Future<void> approveContent(String reportId) async {
    try {
      await _dio.post(
        '${ApiConstants.contentReportDetails.replaceAll('{id}', reportId)}/approve',
      );
    } catch (e) {
      _logger.e('Error approving content: $e');
      rethrow;
    }
  }

  Future<void> rejectContent(String reportId, {String? reason}) async {
    try {
      await _dio.post(
        '${ApiConstants.contentReportDetails.replaceAll('{id}', reportId)}/reject',
        queryParameters: {
          if (reason != null) 'reason': reason,
        },
      );
    } catch (e) {
      _logger.e('Error rejecting content: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getContentStatistics() async {
    try {
      final response = await _dio.get(ApiConstants.contentStatistics);
      final data = response.data;
      return data['data'] ?? data;
    } catch (e) {
      _logger.e('Error getting content statistics: $e');
      rethrow;
    }
  }

  // ==================== SYSTEM HEALTH APIs ====================

  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      final response = await _dio.get(ApiConstants.systemHealth);
      final data = response.data;
      return data['data'] ?? data;
    } catch (e) {
      _logger.e('Error getting system health: $e');
      rethrow;
    }
  }
}