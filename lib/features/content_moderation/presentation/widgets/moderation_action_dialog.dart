import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/report_model.dart';
import '../../data/models/moderation_action_model.dart';
import '../bloc/content_moderation_bloc.dart';

class ModerationActionDialog extends StatefulWidget {
  final ReportModel report;

  const ModerationActionDialog({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  State<ModerationActionDialog> createState() => _ModerationActionDialogState();
}

class _ModerationActionDialogState extends State<ModerationActionDialog> {
  ModerationAction? _selectedAction;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  List<ModerationAction> _getAvailableActions() {
    // Comments can only be deleted, not hidden
    if (widget.report.type == ReportType.comment) {
      return [
        ModerationAction.approve,
        ModerationAction.delete,
        ModerationAction.ignore,
      ];
    }
    // Moments can be hidden or deleted
    return ModerationAction.values;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xử lý báo cáo'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report info
              _buildReportInfo(),
              const SizedBox(height: 24),
              
              // Action selection
              _buildActionSelection(),
              const SizedBox(height: 16),
              
              // Reason input
              _buildReasonInput(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _selectedAction != null && !_isSubmitting
              ? _submitModeration
              : null,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Xác nhận'),
        ),
      ],
    );
  }

  Widget _buildReportInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconForType(widget.report.type),
                size: 20,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                widget.report.type.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lý do: ${widget.report.reason}',
            style: TextStyle(color: Colors.grey[700]),
          ),
          if (widget.report.reporter != null) ...[
            const SizedBox(height: 4),
            Text(
              'Người báo cáo: ${widget.report.reporter!.username}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
          if (widget.report.reportedUser != null) ...[
            const SizedBox(height: 4),
            Text(
              'Bị báo cáo: ${widget.report.reportedUser!.username}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionSelection() {
    final availableActions = _getAvailableActions();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn hành động:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...availableActions.map((action) => RadioListTile<ModerationAction>(
          title: Text(action.displayName),
          subtitle: Text(
            action.description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          value: action,
          groupValue: _selectedAction,
          onChanged: (value) {
            setState(() => _selectedAction = value);
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        )),
      ],
    );
  }

  Widget _buildReasonInput() {
    return TextField(
      controller: _reasonController,
      decoration: const InputDecoration(
        labelText: 'Ghi chú (tùy chọn)',
        hintText: 'Nhập lý do xử lý...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      enabled: !_isSubmitting,
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

  Future<void> _submitModeration() async {
    if (_selectedAction == null) return;

    setState(() => _isSubmitting = true);

    try {
      context.read<ContentModerationBloc>().add(
        TakeAction(
          reportId: widget.report.id,
          action: _selectedAction!,
          reason: _reasonController.text.isNotEmpty
              ? _reasonController.text
              : null,
        ),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã ${_selectedAction!.displayName.toLowerCase()} thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
