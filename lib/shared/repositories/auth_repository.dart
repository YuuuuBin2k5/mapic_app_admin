import '../services/mapic_api_service.dart';

class AuthRepository {
  final MapicApiService _apiService;

  AuthRepository(this._apiService);

  Future<Map<String, dynamic>> login(String username, String password) async {
    return await _apiService.login(username, password);
  }

  Future<void> logout() async {
    await _apiService.logout();
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    return await _apiService.refreshToken(refreshToken);
  }
}