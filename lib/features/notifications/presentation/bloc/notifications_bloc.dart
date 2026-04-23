import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../../../core/di/injection.dart';

// ═══════════════════════════════════════════════════════ Events

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  final NotificationType? typeFilter;
  final NotificationPriority? priorityFilter;
  final bool? isReadFilter;

  const LoadNotifications({
    this.typeFilter,
    this.priorityFilter,
    this.isReadFilter,
  });

  @override
  List<Object?> get props => [typeFilter, priorityFilter, isReadFilter];
}

class RefreshNotifications extends NotificationsEvent {}

class MarkNotificationAsRead extends NotificationsEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationsEvent {}

class DeleteNotification extends NotificationsEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class FilterNotifications extends NotificationsEvent {
  final NotificationType? type;
  final NotificationPriority? priority;
  final bool? isRead;

  const FilterNotifications({
    this.type,
    this.priority,
    this.isRead,
  });

  @override
  List<Object?> get props => [type, priority, isRead];
}

class LoadUnreadCount extends NotificationsEvent {}

// ═══════════════════════════════════════════════════════ States

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final NotificationType? typeFilter;
  final NotificationPriority? priorityFilter;
  final bool? isReadFilter;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    this.typeFilter,
    this.priorityFilter,
    this.isReadFilter,
  });

  @override
  List<Object?> get props => [
        notifications,
        unreadCount,
        typeFilter,
        priorityFilter,
        isReadFilter,
      ];
}

class NotificationActionInProgress extends NotificationsState {
  final String notificationId;
  final String actionType;

  const NotificationActionInProgress({
    required this.notificationId,
    required this.actionType,
  });

  @override
  List<Object?> get props => [notificationId, actionType];
}

class NotificationActionCompleted extends NotificationsState {
  final String message;

  const NotificationActionCompleted(this.message);

  @override
  List<Object?> get props => [message];
}

class UnreadCountLoaded extends NotificationsState {
  final int count;

  const UnreadCountLoaded(this.count);

  @override
  List<Object?> get props => [count];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ═══════════════════════════════════════════════════════ BLoC

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepositoryImpl _repository;

  NotificationsBloc()
      : _repository = getIt<NotificationsRepositoryImpl>(),
        super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<FilterNotifications>(_onFilterNotifications);
    on<LoadUnreadCount>(_onLoadUnreadCount);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      emit(NotificationsLoading());

      final notifications = await _repository.getNotifications(
        type: event.typeFilter,
        priority: event.priorityFilter,
        isRead: event.isReadFilter,
      );

      final unreadCount = await _repository.getUnreadCount();

      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        typeFilter: event.typeFilter,
        priorityFilter: event.priorityFilter,
        isReadFilter: event.isReadFilter,
      ));
    } catch (e) {
      emit(NotificationsError('Không thể tải thông báo: $e'));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final currentState = state;
      NotificationType? typeFilter;
      NotificationPriority? priorityFilter;
      bool? isReadFilter;

      if (currentState is NotificationsLoaded) {
        typeFilter = currentState.typeFilter;
        priorityFilter = currentState.priorityFilter;
        isReadFilter = currentState.isReadFilter;
      }

      final notifications = await _repository.getNotifications(
        type: typeFilter,
        priority: priorityFilter,
        isRead: isReadFilter,
      );

      final unreadCount = await _repository.getUnreadCount();

      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        typeFilter: typeFilter,
        priorityFilter: priorityFilter,
        isReadFilter: isReadFilter,
      ));
    } catch (e) {
      emit(NotificationsError('Không thể làm mới thông báo: $e'));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      emit(NotificationActionInProgress(
        notificationId: event.notificationId,
        actionType: 'mark_read',
      ));

      await _repository.markAsRead(event.notificationId);

      emit(const NotificationActionCompleted('Đã đánh dấu đã đọc'));

      // Reload notifications
      add(RefreshNotifications());
    } catch (e) {
      emit(NotificationsError('Không thể đánh dấu đã đọc: $e'));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      emit(const NotificationActionInProgress(
        notificationId: 'all',
        actionType: 'mark_all_read',
      ));

      await _repository.markAllAsRead();

      emit(const NotificationActionCompleted('Đã đánh dấu tất cả đã đọc'));

      // Reload notifications
      add(RefreshNotifications());
    } catch (e) {
      emit(NotificationsError('Không thể đánh dấu tất cả: $e'));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      emit(NotificationActionInProgress(
        notificationId: event.notificationId,
        actionType: 'delete',
      ));

      await _repository.deleteNotification(event.notificationId);

      emit(const NotificationActionCompleted('Đã xóa thông báo'));

      // Reload notifications
      add(RefreshNotifications());
    } catch (e) {
      emit(NotificationsError('Không thể xóa thông báo: $e'));
    }
  }

  Future<void> _onFilterNotifications(
    FilterNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      emit(NotificationsLoading());

      final notifications = await _repository.getNotifications(
        type: event.type,
        priority: event.priority,
        isRead: event.isRead,
      );

      final unreadCount = await _repository.getUnreadCount();

      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        typeFilter: event.type,
        priorityFilter: event.priority,
        isReadFilter: event.isRead,
      ));
    } catch (e) {
      emit(NotificationsError('Không thể lọc thông báo: $e'));
    }
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final count = await _repository.getUnreadCount();
      emit(UnreadCountLoaded(count));
    } catch (e) {
      emit(NotificationsError('Không thể tải số lượng chưa đọc: $e'));
    }
  }
}
