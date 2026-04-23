import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/content_moderation_bloc.dart';
import '../widgets/report_queue_list.dart';
import '../widgets/moderation_filters.dart';
import '../widgets/moderation_stats_cards.dart';
import '../widgets/moderation_action_dialogs.dart';
import '../../data/models/report_model.dart';
import '../../data/models/moderation_action_model.dart';

class ContentModerationPage extends StatelessWidget {
  const ContentModerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContentModerationBloc()..add(LoadReportQueue()),
      child: const ContentModerationView(),
    );
  }
}

class ContentModerationView extends StatefulWidget {
  const ContentModerationView({super.key});

  @override
  State<ContentModerationView> createState() => _ContentModerationViewState();
}

class _ContentModerationViewState extends State<ContentModerationView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  OverlayEntry? _loadingOverlay;
  
  // Store last action for undo functionality
  String? _lastActionReportId;
  ModerationAction? _lastAction;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _loadingOverlay?.remove();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm Duyệt Nội Dung'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ContentModerationBloc>().add(RefreshReportQueue());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to moderation settings
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm báo cáo...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<ContentModerationBloc>().add(
                          LoadReportQueue(searchQuery: ''),
                        );
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  onSubmitted: (query) {
                    context.read<ContentModerationBloc>().add(
                      LoadReportQueue(searchQuery: query),
                    );
                  },
                ),
              ),
              // Tab bar
              TabBar(
                controller: _tabController,
                onTap: (index) {
                  ReportType? filterType;
                  switch (index) {
                    case 0:
                      filterType = null; // All
                      break;
                    case 1:
                      filterType = ReportType.moment;
                      break;
                    case 2:
                      filterType = ReportType.comment;
                      break;
                  }
                  context.read<ContentModerationBloc>().add(
                    FilterReports(type: filterType),
                  );
                },
                tabs: const [
                  Tab(text: 'Tất cả'),
                  Tab(text: 'Moments'),
                  Tab(text: 'Comments'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<ContentModerationBloc, ContentModerationState>(
        listener: (context, state) {
          // Remove loading overlay when action completes or fails
          if (state is ActionCompleted || state is ContentModerationError) {
            _loadingOverlay?.remove();
            _loadingOverlay = null;
          }

          if (state is ActionInProgress) {
            // Show loading overlay
            _loadingOverlay = ModerationActionDialogs.showLoadingOverlay(
              context,
              'Đang xử lý...',
            );
          } else if (state is ActionCompleted) {
            // Store for undo
            _lastActionReportId = state.reportId;
            _lastAction = state.action;

            // Show success with undo option
            ModerationActionDialogs.showSuccess(
              context: context,
              message: state.message,
              onUndo: () => _handleUndo(context),
            );
          } else if (state is ContentModerationError) {
            // Show error with retry option
            ModerationActionDialogs.showError(
              context: context,
              message: state.message,
              onRetry: () {
                // Retry last action if available
                if (_lastActionReportId != null && _lastAction != null) {
                  context.read<ContentModerationBloc>().add(
                    TakeAction(
                      reportId: _lastActionReportId!,
                      action: _lastAction!,
                    ),
                  );
                }
              },
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Stats cards
              if (state is ReportQueueLoaded) ...[
                ModerationStatsCards(
                  totalCount: state.totalCount,
                  pendingCount: state.pendingCount,
                  reviewedCount: state.reviewedCount,
                ),
                const SizedBox(height: 8),
                // Filters
                ModerationFilters(
                  activeFilter: state.activeFilter,
                  statusFilter: state.statusFilter,
                  onFilterChanged: (type, status, reason) {
                    context.read<ContentModerationBloc>().add(
                      FilterReports(type: type, status: status, reason: reason),
                    );
                  },
                ),
              ],
              // Content
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to bulk actions
          _showBulkActionsDialog(context);
        },
        icon: const Icon(Icons.checklist),
        label: const Text('Hành động hàng loạt'),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ContentModerationState state) {
    if (state is ContentModerationLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải danh sách báo cáo...'),
          ],
        ),
      );
    }

    if (state is ReportQueueLoaded) {
      if (state.reports.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Không có báo cáo nào',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Tất cả báo cáo đã được xử lý',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        );
      }

      return ReportQueueList(
        reports: state.reports,
        onReportTap: (report) {
          _showReportDetailsDialog(context, report);
        },
        onActionTap: (report, action) {
          _showActionConfirmationDialog(context, report, action);
        },
      );
    }

    if (state is ContentModerationError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ContentModerationBloc>().add(LoadReportQueue());
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showReportDetailsDialog(BuildContext context, ReportModel report) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Chi tiết báo cáo #${report.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Loại', report.type.displayName),
              _buildDetailRow('Lý do', '${report.reason.icon} ${report.reason.displayName}'),
              _buildDetailRow('Số lượt báo cáo', '${report.reportCount}'),
              _buildDetailRow('Thời gian', _formatDateTime(report.createdAt)),
              _buildDetailRow('Trạng thái', report.status.name),
              if (report.contentPreview != null) ...[
                const SizedBox(height: 8),
                const Text('Nội dung:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(report.contentPreview!),
              ],
              if (report.imageUrl != null) ...[
                const SizedBox(height: 8),
                const Text('Hình ảnh:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      report.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // TODO: Navigate to full report details page
            },
            child: const Text('Xem chi tiết'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showActionConfirmationDialog(
    BuildContext context,
    ReportModel report,
    ModerationAction action,
  ) async {
    // Show modern confirmation sheet
    final confirmed = await ModerationActionDialogs.showConfirmation(
      context: context,
      report: report,
      action: action,
    );

    // If confirmed, dispatch action
    if (confirmed == true && context.mounted) {
      // Store for potential undo
      _lastActionReportId = report.id;
      _lastAction = action;

      // Dispatch action to BLoC
      context.read<ContentModerationBloc>().add(
        TakeAction(reportId: report.id, action: action),
      );
    }
  }

  void _handleUndo(BuildContext context) {
    if (_lastActionReportId == null || _lastAction == null) return;

    // For now, show a message that undo is not available for destructive actions
    // In a real implementation, you would need backend support for restore/undo
    if (_lastAction == ModerationAction.delete) {
      ModerationActionDialogs.showError(
        context: context,
        message: 'Không thể hoàn tác hành động xóa',
      );
    } else if (_lastAction == ModerationAction.hide) {
      // Could potentially restore hidden content
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tính năng hoàn tác đang được phát triển'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // For other actions, just refresh to show current state
      context.read<ContentModerationBloc>().add(RefreshReportQueue());
    }

    // Clear undo state
    _lastActionReportId = null;
    _lastAction = null;
  }

  void _showBulkActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hành động hàng loạt'),
        content: const Text('Tính năng này sẽ được phát triển trong phiên bản tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}