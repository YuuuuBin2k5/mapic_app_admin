import '../../../../shared/services/mapic_api_service.dart';
import '../models/user_profile_model.dart';

class UserManagementRepositoryImpl {
  final MapicApiService _apiService;

  UserManagementRepositoryImpl(this._apiService);

  Future<List<UserProfileModel>> getUsers({
    int page = 0,
    int size = 20,
    String? search,
    UserStatus? status,
  }) async {
    final result = await _apiService.getUsers(
      page: page,
      size: size,
      search: search,
      status: status,
    );
    return result['content'] as List<UserProfileModel>;
  }

  Future<UserProfileModel> getUserById(String userId) async {
    return await _apiService.getUserById(userId);
  }

  Future<void> updateUserStatus(String userId, UserStatus status) async {
    await _apiService.updateUserStatus(userId, status);
  }

  Future<Map<String, dynamic>> getUserActivity(String userId, {int days = 7}) async {
    return await _apiService.getUserActivity(userId, days: days);
  }

  Future<List<UserProfileModel>> searchUsers(String query, {int page = 0, int size = 20}) async {
    return await _apiService.searchUsers(query, page: page, size: size);
  }

  // Added missing methods required by UserManagementBloc
  Future<void> banUser(String userId, BanType banType, {required String reason, DateTime? expiresAt}) async {
    // Stub: Forward to updateUserStatus for now
    await _apiService.updateUserStatus(userId, UserStatus.banned);
  }

  Future<void> warnUser(String userId, {required String reason, String? message}) async {
    // Stub: Forward to updateUserStatus for now
    await _apiService.updateUserStatus(userId, UserStatus.warning);
  }

  Future<void> unbanUser(String userId) async {
    // Stub: Forward to updateUserStatus for now
    await _apiService.updateUserStatus(userId, UserStatus.active);
  }

  Future<List<UserProfileModel>> getLinkedAccounts(String deviceId) async {
    // Stub: Return empty list for now
    return [];
  }
}