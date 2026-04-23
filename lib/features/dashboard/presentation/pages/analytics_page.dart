import 'package:flutter/material.dart';

import '../widgets/user_growth_chart.dart';
import '../widgets/reports_bar_chart.dart';
import '../widgets/content_pie_chart.dart';
import '../widgets/date_range_selector.dart';
import '../../../../shared/models/chart_data_models.dart';
import '../../../../shared/utils/chart_mock_data.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DateRange _selectedRange = DateRange.last7Days;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích & Thống kê'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Refresh data
              });
            },
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang xuất báo cáo...')),
              );
            },
            tooltip: 'Xuất báo cáo',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Selector
            DateRangeSelector(
              selectedRange: _selectedRange,
              onRangeChanged: (range) {
                setState(() {
                  _selectedRange = range;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // User Growth Chart
            UserGrowthChart(
              data: ChartMockData.generateUserGrowthData(_selectedRange),
              dateRange: _selectedRange,
            ),
            
            const SizedBox(height: 16),
            
            // Reports Bar Chart
            ReportsBarChart(
              data: ChartMockData.generateReportsByReasonData(),
            ),
            
            const SizedBox(height: 16),
            
            // Content Pie Chart
            ContentPieChart(
              data: ChartMockData.generateContentDistributionData(),
            ),
            
            const SizedBox(height: 16),
            
            // Summary Card
            _buildSummaryCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tổng quan',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              'Tổng báo cáo',
              '132',
              Icons.report,
              Colors.orange,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              context,
              'Tỷ lệ xử lý',
              '94.5%',
              Icons.check_circle,
              Colors.green,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              context,
              'Thời gian phản hồi TB',
              '2.3 giờ',
              Icons.timer,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
