import '../services/mapic_api_service.dart';

class DashboardRepository {
  final MapicApiService _apiService;

  DashboardRepository(this._apiService);

  Future<Map<String, dynamic>> getDashboardMetrics() async {
    return await _apiService.getDashboardMetrics();
  }

  Future<List<Map<String, dynamic>>> getTrendData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _apiService.getTrendData(
      startDate: startDate,
      endDate: endDate,
    );
  }
}