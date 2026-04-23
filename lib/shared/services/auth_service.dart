import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  Future<void> saveTokens(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    
    // Simple check - in real app, verify JWT expiration
    return token.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData == null) return null;
    
    // In real app, parse JSON
    return {'username': 'admin', 'role': 'ADMIN'};
  }

  Future<String?> getUserRole() async {
    final userData = await getUserData();
    return userData?['role'] as String?;
  }

  Future<String?> getUserId() async {
    final userData = await getUserData();
    return userData?['userId']?.toString();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> hasPermission(String permission) async {
    final role = await getUserRole();
    
    switch (role) {
      case 'SUPER_ADMIN':
        return true;
      case 'ADMIN':
        return _adminPermissions.contains(permission);
      case 'MANAGER':
        return _managerPermissions.contains(permission);
      case 'MODERATOR':
        return _moderatorPermissions.contains(permission);
      default:
        return false;
    }
  }

  static const List<String> _adminPermissions = [
    'dashboard.view',
    'users.view',
    'users.edit',
    'users.suspend',
    'content.view',
    'content.moderate',
    'analytics.view',
    'settings.view',
    'settings.edit',
  ];

  static const List<String> _managerPermissions = [
    'dashboard.view',
    'users.view',
    'content.view',
    'content.moderate',
    'analytics.view',
  ];

  static const List<String> _moderatorPermissions = [
    'content.view',
    'content.moderate',
    'users.view',
  ];
}