import '../../../../shared/services/mapic_api_service.dart';
import '../models/report_model.dart';
import '../models/moderation_action_model.dart';

class ContentModerationRepositoryImpl {
  final MapicApiService _apiService;

  ContentModerationRepositoryImpl(this._apiService);

  Future<Map<String, dynamic>> getReportQueue({
    ReportType? type,
    ReportStatus? status,
    ReportReason? reason,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    return await _apiService.getReportQueue(
      type: type,
      status: status,
      reason: reason,
      search: search,
      page: page,
      size: size,
    );
  }

  Future<ReportModel> getReportDetails(String reportId) async {
    return await _apiService.getReportDetails(reportId);
  }

  Future<void> moderateContent(
    String reportId,
    ModerationAction action, {
    String? reason,
    String? note,
  }) async {
    await _apiService.moderateContent(
      reportId,
      action,
      reason: reason,
      note: note,
    );
  }

  Future<void> approveContent(String reportId) async {
    await _apiService.approveContent(reportId);
  }

  Future<void> rejectContent(String reportId, {String? reason}) async {
    await _apiService.rejectContent(reportId, reason: reason);
  }

  Future<Map<String, dynamic>> getContentStatistics() async {
    return await _apiService.getContentStatistics();
  }
}