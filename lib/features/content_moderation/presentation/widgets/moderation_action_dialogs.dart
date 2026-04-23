import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/report_model.dart';
import '../../data/models/moderation_action_model.dart';

/// Modern confirmation bottom sheet for moderation actions
/// Shows context-rich preview with smooth animations
class ModerationActionDialogs {
  /// Show confirmation sheet for moderation action
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required ReportModel report,
    required ModerationAction action,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ConfirmationSheet(
        report: report,
        action: action,
      ),
    );
  }

  /// Show loading overlay while processing
  static OverlayEntry showLoadingOverlay(
    BuildContext context,
    String message,
  ) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => _LoadingOverlay(message: message),
    );
    overlay.insert(entry);
    return entry;
  }

  /// Show success message with undo option
  static void showSuccess({
    required BuildContext context,
    required String message,
    required VoidCallback onUndo,
    Duration duration = const Duration(seconds: 5),
  }) {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'HOÀN TÁC',
          textColor: Colors.white,
          onPressed: onUndo,
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show error with retry option
  static void showError({
    required BuildContext context,
    required String message,
    VoidCallback? onRetry,
  }) {
    // Haptic feedback
    HapticFeedback.heavyImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        action: onRetry != null
            ? SnackBarAction(
                label: 'THỬ LẠI',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

/// Confirmation sheet widget
class _ConfirmationSheet extends StatelessWidget {
  final ReportModel report;
  final ModerationAction action;

  const _ConfirmationSheet({
    required this.report,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Action icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _getActionColor(action, colorScheme).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        action.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Xác nhận ${action.displayName}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    _getActionDescription(action),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Report preview
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        report.reason.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          report.reason.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${report.reportCount} báo cáo',
                          style: TextStyle(
                            color: colorScheme.onErrorContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (report.contentPreview != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      report.contentPreview!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Impact message
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getActionColor(action, colorScheme).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getActionColor(action, colorScheme).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _getActionColor(action, colorScheme),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getImpactMessage(action),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getActionColor(action, colorScheme),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getActionColor(action, colorScheme),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(action.displayName),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor(ModerationAction action, ColorScheme colorScheme) {
    switch (action) {
      case ModerationAction.delete:
        return Colors.red;
      case ModerationAction.hide:
        return Colors.orange;
      case ModerationAction.warn:
        return Colors.amber;
      case ModerationAction.ignore:
        return colorScheme.outline;
      default:
        return colorScheme.primary;
    }
  }

  String _getActionDescription(ModerationAction action) {
    switch (action) {
      case ModerationAction.delete:
        return 'Nội dung sẽ bị xóa vĩnh viễn và không thể khôi phục';
      case ModerationAction.hide:
        return 'Nội dung sẽ bị ẩn khỏi feed nhưng vẫn có thể khôi phục';
      case ModerationAction.warn:
        return 'Người dùng sẽ nhận được cảnh báo về nội dung vi phạm';
      case ModerationAction.ignore:
        return 'Báo cáo sẽ bị bỏ qua và nội dung vẫn hiển thị';
      default:
        return 'Xác nhận hành động này';
    }
  }

  String _getImpactMessage(ModerationAction action) {
    switch (action) {
      case ModerationAction.delete:
        return 'Hành động này không thể hoàn tác';
      case ModerationAction.hide:
        return 'Bạn có thể hoàn tác trong vòng 5 giây';
      case ModerationAction.warn:
        return 'Người dùng sẽ nhận được thông báo';
      case ModerationAction.ignore:
        return 'Báo cáo sẽ được đánh dấu là đã xử lý';
      default:
        return '';
    }
  }
}

/// Loading overlay widget
class _LoadingOverlay extends StatelessWidget {
  final String message;

  const _LoadingOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
