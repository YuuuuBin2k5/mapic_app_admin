class ApiConstants {
  // ── Base URLs ──────────────────────────────────────────────────────────────
  // IMPORTANT: Update this based on your setup:
  // - Emulator: 'http://10.0.2.2:8080/api/admin'
  // - Physical device on same WiFi: 'http://YOUR_PC_IP:8080/api/admin'
  // - ADB reverse: 'http://localhost:8080/api/admin' (after: adb reverse tcp:8080 tcp:8080)
  
  // TODO: Change this to your PC's IP address when using physical device
  static const String baseUrl = 'http://192.168.1.6:8080/api'; // Point to base API
  static const String wsBaseUrl = 'ws://192.168.1.6:8080/chat-socket'; // UPDATE THIS!

  // ── Admin Auth ─────────────────────────────────────────────────────────────
  static const String authLogin = '/admin/auth/login';
  static const String authLogout = '/admin/auth/logout';
  static const String authRefresh = '/admin/auth/refresh';
  static const String authProfile = '/admin/auth/profile';

  // ── Dashboard ──────────────────────────────────────────────────────────────
  static const String dashboardMetrics = '/admin/dashboard/metrics';
  static const String dashboardTrends = '/admin/dashboard/trends';

  // ── User Management ────────────────────────────────────────────────────────
  static const String users = '/admin/users';
  static const String userById = '/admin/users/{id}';
  static const String userStatus = '/admin/users/{id}/status';
  static const String userActivity = '/admin/users/{id}/activity';
  static const String userBan = '/admin/users/{id}/ban';
  static const String userUnban = '/admin/users/{id}/unban';
  static const String userWarn = '/admin/users/{id}/warn';
  static const String userSearch = '/admin/users/search';

  // ── Content Moderation ─────────────────────────────────────────────────────
  static const String contentQueue = '/admin/content/queue';
  static const String contentReportDetails = '/admin/content/reports/{id}';
  static const String contentModerate = '/admin/content/reports/{id}/moderate';
  static const String contentAnalytics = '/admin/content/analytics';
  static const String contentStatistics = '/admin/content/statistics';

  // ── System ─────────────────────────────────────────────────────────────────
  static const String systemHealth = '/admin/system/health';

  // ── WebSocket Channels ─────────────────────────────────────────────────────
  static const String wsChannelUserActivity = 'user_activity';
  static const String wsChannelContentQueue = 'content_queue';
  static const String wsChannelSystemHealth = 'system_health';
}