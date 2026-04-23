import 'dart:math';
import '../models/chart_data_models.dart';

class ChartMockData {
  static List<UserGrowthDataPoint> generateUserGrowthData(DateRange range) {
    final now = DateTime.now();
    final days = range.days;
    final random = Random();
    
    return List.generate(days, (index) {
      final date = now.subtract(Duration(days: days - index - 1));
      final baseCount = 1000 + (index * 50);
      final variance = random.nextInt(100) - 50;
      
      return UserGrowthDataPoint(
        date: date,
        userCount: baseCount + variance,
      );
    });
  }

  static List<ReportsByReasonData> generateReportsByReasonData() {
    return const [
      ReportsByReasonData(
        reason: 'Spam',
        count: 45,
        colorValue: 0xFFF44336, // Red
      ),
      ReportsByReasonData(
        reason: 'Nude',
        count: 32,
        colorValue: 0xFFFF9800, // Orange
      ),
      ReportsByReasonData(
        reason: 'Hate',
        count: 28,
        colorValue: 0xFFFFC107, // Amber
      ),
      ReportsByReasonData(
        reason: 'Fake',
        count: 15,
        colorValue: 0xFF2196F3, // Blue
      ),
      ReportsByReasonData(
        reason: 'Other',
        count: 12,
        colorValue: 0xFF9E9E9E, // Gray
      ),
    ];
  }

  static List<ContentDistributionData> generateContentDistributionData() {
    const total = 1000;
    const moments = 600;
    const comments = 250;
    const reports = 150;

    return [
      ContentDistributionData(
        type: 'Moments',
        count: moments,
        percentage: (moments / total) * 100,
        colorValue: ChartColors.primary,
      ),
      ContentDistributionData(
        type: 'Comments',
        count: comments,
        percentage: (comments / total) * 100,
        colorValue: ChartColors.secondary,
      ),
      ContentDistributionData(
        type: 'Reports',
        count: reports,
        percentage: (reports / total) * 100,
        colorValue: ChartColors.tertiary,
      ),
    ];
  }
}
