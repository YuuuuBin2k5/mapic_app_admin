import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/content_moderation_bloc.dart';
import '../widgets/moderation_action_dialog.dart';
import '../../data/models/report_model.dart';
import '../../data/models/moderation_action_model.dart';

class ContentModerationPage extends StatelessWidget {
  const ContentModerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContentModerationBloc()..add(const LoadReportQueue()),
      child: const ContentModerationView(),
    );
  }
}

class ContentModerationView extends StatefulWidget {
  const ContentModerationView({super.key});

  @override
  State<ContentModerationView> createState() => _ContentModerationViewState();
}

class _ContentModerationViewState extends State<ContentModerationView> {
  ReportType? _selectedType;
  ReportStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm Duyệt Nội Dung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ContentModerationBloc>().add(RefreshReportQueue());
            },
          ),
        ],
      ),
      body: BlocConsumer<ContentModerationBloc, ContentModerationState>(
        listener: (context, state) {
          if (state is ActionCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ContentModerationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Statistics Cards
              if (state is ReportQueueLoaded) _buildStatistics(state),
              
              // Filters
              _buildFilters(context),
              
              // Report List
              Expanded(child: _buildContent(context, state)),
              
              // Pagination
              if (state is ReportQueueLoaded) _buildPagination(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatistics(ReportQueueLoaded state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _buildStatCard(
            'Tổng số',
            state.totalElements.toString(),
            Icons.report,
            Colors.blue,
          ),
          _buildStatCard(
            'Chờ xử lý',
            state.pendingCount.toString(),
            Icons.pending,
            Colors.orange,
          ),
          _buildStatCard(
            'Đã xử lý',
            state.reviewedCount.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Type filter
          Expanded(
            child: DropdownButtonFormField<ReportType>(
              decoration: const InputDecoration(
                labelText: 'Loại',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: _selectedType,
              items: [
                const DropdownMenuItem(value: null, child: Text('Tất cả')),
                ...ReportType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                )),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
                context.read<ContentModerationBloc>().add(
                  LoadReportQueue(filterType: value, filterStatus: _selectedStatus),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // Status filter
          Expanded(
            child: DropdownButtonFormField<ReportStatus>(
              decoration: const InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: _selectedStatus,
              items: [
                const DropdownMenuItem(value: null, child: Text('Tất cả')),
                ...ReportStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                )),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                context.read<ContentModerationBloc>().add(
                  LoadReportQueue(filterType: _selectedType, filterStatus: value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ContentModerationState state) {
    if (state is ContentModerationLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ReportQueueLoaded) {
      if (state.reports.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Không có báo cáo nào'),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.reports.length,
        itemBuilder: (context, index) {
          final report = state.reports[index];
          return _buildReportCard(context, report);
        },
      );
    }

    if (state is ContentModerationError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ContentModerationBloc>().add(const LoadReportQueue());
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildReportCard(BuildContext context, ReportModel report) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(
          _getIconForType(report.type),
          color: report.status == ReportStatus.pending ? Colors.orange : Colors.green,
          size: 32,
        ),
        title: Text('${report.type.displayName} Report'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lý do: ${report.reason.displayName}', 
                 style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            if (report.reporter != null)
              Text('Từ: ${report.reporter!.username}', 
                   style: const TextStyle(fontSize: 11), 
                   maxLines: 1, 
                   overflow: TextOverflow.ellipsis),
            if (report.reportedUser != null)
              Text('Bị báo cáo: ${report.reportedUser!.username}', 
                   style: const TextStyle(fontSize: 11),
                   maxLines: 1, 
                   overflow: TextOverflow.ellipsis),
            Text(_formatDate(report.createdAt), 
                 style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        trailing: report.status == ReportStatus.pending
            ? SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 22),
                      onPressed: () => _approveReport(context, report),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.gavel_outlined, color: Colors.red, size: 22),
                      onPressed: () => _showModerationDialog(context, report),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              )
            : Chip(
                label: Text(report.status.displayName),
                backgroundColor: Colors.green.shade100,
              ),
        onTap: () => _showReportDetails(context, report),
      ),
    );
  }

  IconData _getIconForType(ReportType type) {
    switch (type) {
      case ReportType.moment:
        return Icons.photo;
      case ReportType.comment:
        return Icons.comment;
      case ReportType.userProfile:
        return Icons.person;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  void _approveReport(BuildContext context, ReportModel report) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Chấp nhận báo cáo này (nội dung OK)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ContentModerationBloc>().add(
                TakeAction(
                  reportId: report.id,
                  action: ModerationAction.approve,
                ),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showModerationDialog(BuildContext context, ReportModel report) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ContentModerationBloc>(),
        child: ModerationActionDialog(report: report),
      ),
    );
  }

  void _showReportDetails(BuildContext context, ReportModel report) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Chi tiết báo cáo #${report.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Loại', '${report.type.icon} ${report.type.displayName}'),
              _buildDetailRow('Lý do', '${report.reason.icon} ${report.reason.displayName}'),
              _buildDetailRow('Số lượt báo cáo', '${report.reportCount}'),
              _buildDetailRow('Trạng thái', '${report.status.icon} ${report.status.displayName}'),
              _buildDetailRow('Thời gian', _formatDate(report.createdAt)),
              
              if (report.reasonDetail != null) ...[
                const SizedBox(height: 12),
                const Text('Mô tả chi tiết:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(report.reasonDetail!),
                ),
              ],

              if (report.contentPreview != null && report.contentPreview!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Nội dung văn bản:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(report.contentPreview!),
              ],

              if (report.content?.mediaUrls != null && report.content!.mediaUrls!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Media (${report.content!.mediaUrls!.length}):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: report.content!.mediaUrls!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            report.content!.mediaUrls![index],
                            width: 140,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 140,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: constraints.maxWidth * 0.35,
                child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              Expanded(
                child: Text(value, style: const TextStyle(fontSize: 13)),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildPagination(BuildContext context, ReportQueueLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: state.currentPage > 0
                ? () {
                    context.read<ContentModerationBloc>().add(
                      LoadReportQueue(
                        page: state.currentPage - 1,
                        filterType: state.activeFilter,
                        filterStatus: state.statusFilter,
                      ),
                    );
                  }
                : null,
          ),
          Text('Trang ${state.currentPage + 1} / ${state.totalPages}'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: state.currentPage < state.totalPages - 1
                ? () {
                    context.read<ContentModerationBloc>().add(
                      LoadReportQueue(
                        page: state.currentPage + 1,
                        filterType: state.activeFilter,
                        filterStatus: state.statusFilter,
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
