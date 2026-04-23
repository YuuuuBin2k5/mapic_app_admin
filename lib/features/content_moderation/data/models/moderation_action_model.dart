enum ModerationAction {
  approve,  // Approve content (report invalid)
  delete,   // Delete content
  hide,     // Hide content (moments only)
  ignore,   // Ignore report
  warn,     // Warn user
}

extension ModerationActionExtension on ModerationAction {
  String get displayName {
    switch (this) {
      case ModerationAction.approve:
        return 'Chấp nhận';
      case ModerationAction.delete:
        return 'Xóa';
      case ModerationAction.hide:
        return 'Ẩn';
      case ModerationAction.ignore:
        return 'Bỏ qua';
      case ModerationAction.warn:
        return 'Cảnh cáo';
    }
  }
  
  String get description {
    switch (this) {
      case ModerationAction.approve:
        return 'Báo cáo không hợp lệ, nội dung OK';
      case ModerationAction.delete:
        return 'Xóa nội dung vi phạm';
      case ModerationAction.hide:
        return 'Ẩn nội dung (chỉ moments)';
      case ModerationAction.ignore:
        return 'Bỏ qua báo cáo này';
      case ModerationAction.warn:
        return 'Gửi cảnh cáo đến người dùng';
    }
  }

  String get icon {
    switch (this) {
      case ModerationAction.approve:
        return '✅';
      case ModerationAction.delete:
        return '🗑️';
      case ModerationAction.hide:
        return '👁️‍🗨️';
      case ModerationAction.ignore:
        return '⏭️';
      case ModerationAction.warn:
        return '⚠️';
    }
  }
}
