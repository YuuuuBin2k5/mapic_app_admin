import 'package:equatable/equatable.dart';

/// User growth data point
class UserGrowthDataPoint extends Equatable {
  final DateTime date;
  final int userCount;

  const UserGrowthDataPoint({
    required this.date,
    required this.userCount,
  });

  @override
  List<Object?> get props => [date, userCount];
}

/// Reports by reason data
class ReportsByReasonData extends Equatable {
  final String reason;
  final int count;
  final int colorValue;

  const ReportsByReasonData({
    required this.reason,
    required this.count,
    required this.colorValue,
  });

  @override
  List<Object?> get props => [reason, count, colorValue];
}

/// Content distribution data
class ContentDistributionData extends Equatable {
  final String type;
  final int count;
  final double percentage;
  final int colorValue;

  const ContentDistributionData({
    required this.type,
    required this.count,
    required this.percentage,
    required this.colorValue,
  });

  @override
  List<Object?> get props => [type, count, percentage, colorValue];
}

/// Date range for filtering
enum DateRange {
  last7Days,
  last30Days,
  last90Days,
  custom,
}

extension DateRangeExtension on DateRange {
  String get displayName {
    switch (this) {
      case DateRange.last7Days:
        return '7 ngày qua';
      case DateRange.last30Days:
        return '30 ngày qua';
      case DateRange.last90Days:
        return '90 ngày qua';
      case DateRange.custom:
        return 'Tùy chỉnh';
    }
  }

  int get days {
    switch (this) {
      case DateRange.last7Days:
        return 7;
      case DateRange.last30Days:
        return 30;
      case DateRange.last90Days:
        return 90;
      case DateRange.custom:
        return 0;
    }
  }
}

/// Chart colors
class ChartColors {
  static const primary = 0xFF4361EE;
  static const secondary = 0xFF7209B7;
  static const tertiary = 0xFFF72585;
  static const quaternary = 0xFF4CC9F0;
  static const quinary = 0xFF06FFA5;
  
  static const List<int> chartColors = [
    primary,
    secondary,
    tertiary,
    quaternary,
    quinary,
  ];
}
