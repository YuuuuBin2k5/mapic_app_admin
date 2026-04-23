import 'package:flutter/material.dart';

import '../../data/models/report_model.dart';
import '../../data/models/moderation_action_model.dart';

class ReportQueueList extends StatelessWidget {
  final List<ReportModel> reports;
  final Function(ReportModel) onReportTap;
  final Function(ReportModel, ModerationAction) onActionTap;

  const ReportQueueList({
    super.key,
    required this.reports,
    required this.onReportTap,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return ReportCard(
          report: report,
          onTap: () => onReportTap(report),
          onActionTap: (action) => onActionTap(report, action),
        );
      },
    );
  }
}

class ReportCard extends StatefulWidget {
  final ReportModel report;
  final VoidCallback onTap;
  final Function(ModerationAction) onActionTap;

  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
    required this.onActionTap,
  });

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getBorderColor(colorScheme),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          // Priority indicator
                          Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(colorScheme),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Content info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.report.reason.icon,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.report.reason.displayName,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (widget.report.reasonDetail != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              widget.report.reasonDetail!,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: colorScheme.outline,
                                                fontStyle: FontStyle.italic,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatusChip(colorScheme),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.report.type.displayName} • ${widget.report.reportCount} báo cáo',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Content preview
                      if (widget.report.contentPreview != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.report.contentPreview!,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Image preview
                      if (widget.report.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant,
                            ),
                            child: Image.network(
                              widget.report.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 32,
                                    color: colorScheme.outline,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Footer with actions
                      Row(
                        children: [
                          Text(
                            _formatDateTime(widget.report.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                          const Spacer(),
                          if (widget.report.status == ReportStatus.pending) ...[
                            _buildActionButton(
                              context,
                              ModerationAction.ignore,
                              colorScheme.outline,
                            ),
                            const SizedBox(width: 8),
                            _buildActionButton(
                              context,
                              ModerationAction.hide,
                              colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            _buildActionButton(
                              context,
                              ModerationAction.delete,
                              colorScheme.error,
                            ),
                          ] else ...[
                            Icon(
                              Icons.check_circle,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Đã xử lý',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (widget.report.status) {
      case ReportStatus.pending:
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        text = 'Chờ xử lý';
        break;
      case ReportStatus.reviewed:
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        text = 'Đã xem';
        break;
      case ReportStatus.resolved:
        backgroundColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        text = 'Đã giải quyết';
        break;
      case ReportStatus.dismissed:
        backgroundColor = colorScheme.surfaceVariant;
        textColor = colorScheme.onSurfaceVariant;
        text = 'Đã bỏ qua';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ModerationAction action,
    Color color,
  ) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: _isProcessing
            ? null
            : () {
                setState(() => _isProcessing = true);
                widget.onActionTap(action);
                // Reset processing state after a delay
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() => _isProcessing = false);
                  }
                });
              },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                action.icon,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                action.displayName,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(ColorScheme colorScheme) {
    switch (widget.report.status) {
      case ReportStatus.pending:
        return colorScheme.error.withOpacity(0.3);
      case ReportStatus.reviewed:
        return colorScheme.primary.withOpacity(0.3);
      default:
        return colorScheme.outline.withOpacity(0.2);
    }
  }

  Color _getPriorityColor(ColorScheme colorScheme) {
    // Priority based on report count and reason
    if (widget.report.reportCount >= 5 ||
        widget.report.reason == ReportReason.inappropriate ||
        widget.report.reason == ReportReason.violence ||
        widget.report.reason == ReportReason.hateSpeech) {
      return colorScheme.error; // High priority
    } else if (widget.report.reportCount >= 3) {
      return Colors.orange; // Medium priority
    } else {
      return colorScheme.primary; // Low priority
    }
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