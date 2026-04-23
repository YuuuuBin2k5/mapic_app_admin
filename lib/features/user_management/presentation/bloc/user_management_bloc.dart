import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/user_profile_model.dart';
import '../../data/repositories/user_management_repository_impl.dart';
import '../../../../core/di/injection.dart';

// ═══════════════════════════════════════════════════════ Events

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserManagementEvent {
  final String? searchQuery;
  final UserStatus? statusFilter;
  final int page;
  final int limit;

  const LoadUsers({
    this.searchQuery,
    this.statusFilter,
    this.page = 0,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [searchQuery, statusFilter, page, limit];
}

class SearchUsers extends UserManagementEvent {
  final String query;
  const SearchUsers(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadUserDetails extends UserManagementEvent {
  final String userId;
  const LoadUserDetails(this.userId);

  @override
  List<Object?> get props => [userId];
}

class BanUser extends UserManagementEvent {
  final String userId;
  final BanType banType;
  final String reason;
  final DateTime? expiresAt;

  const BanUser({
    required this.userId,
    required this.banType,
    required this.reason,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [userId, banType, reason, expiresAt];
}

class WarnUser extends UserManagementEvent {
  final String userId;
  final String reason;
  final String? message;

  const WarnUser({
    required this.userId,
    required this.reason,
    this.message,
  });

  @override
  List<Object?> get props => [userId, reason, message];
}

class UnbanUser extends UserManagementEvent {
  final String userId;
  final String reason;

  const UnbanUser({
    required this.userId,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, reason];
}

class FilterUsers extends UserManagementEvent {
  final UserStatus? status;
  final double? minRiskScore;
  final double? maxRiskScore;
  final DateTime? joinedAfter;
  final DateTime? joinedBefore;

  const FilterUsers({
    this.status,
    this.minRiskScore,
    this.maxRiskScore,
    this.joinedAfter,
    this.joinedBefore,
  });

  @override
  List<Object?> get props => [
        status,
        minRiskScore,
        maxRiskScore,
        joinedAfter,
        joinedBefore,
      ];
}

class LoadLinkedAccounts extends UserManagementEvent {
  final String deviceId;
  const LoadLinkedAccounts(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

// ═══════════════════════════════════════════════════════ States

abstract class UserManagementState extends Equatable {
  const UserManagementState();

  @override
  List<Object?> get props => [];
}

class UserManagementInitial extends UserManagementState {}

class UserManagementLoading extends UserManagementState {}

class UsersLoaded extends UserManagementState {
  final List<UserProfileModel> users;
  final String? searchQuery;
  final UserStatus? statusFilter;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;

  const UsersLoaded({
    required this.users,
    this.searchQuery,
    this.statusFilter,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [
        users,
        searchQuery,
        statusFilter,
        currentPage,
        totalPages,
        totalCount,
        hasMore,
      ];
}

class UserDetailsLoaded extends UserManagementState {
  final UserProfileModel user;
  final List<UserProfileModel> linkedAccounts;
  final Map<String, dynamic>? additionalData;

  const UserDetailsLoaded({
    required this.user,
    required this.linkedAccounts,
    this.additionalData,
  });

  @override
  List<Object?> get props => [user, linkedAccounts, additionalData];
}

class UserActionInProgress extends UserManagementState {
  final String userId;
  final String actionType;

  const UserActionInProgress({
    required this.userId,
    required this.actionType,
  });

  @override
  List<Object?> get props => [userId, actionType];
}

class UserActionCompleted extends UserManagementState {
  final String userId;
  final String actionType;
  final String message;

  const UserActionCompleted({
    required this.userId,
    required this.actionType,
    required this.message,
  });

  @override
  List<Object?> get props => [userId, actionType, message];
}

class LinkedAccountsLoaded extends UserManagementState {
  final String deviceId;
  final List<UserProfileModel> linkedAccounts;

  const LinkedAccountsLoaded({
    required this.deviceId,
    required this.linkedAccounts,
  });

  @override
  List<Object?> get props => [deviceId, linkedAccounts];
}

class UserManagementError extends UserManagementState {
  final String message;
  final String? errorCode;

  const UserManagementError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

// ═══════════════════════════════════════════════════════ BLoC

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final UserManagementRepositoryImpl _repository;

  UserManagementBloc()
      : _repository = getIt<UserManagementRepositoryImpl>(),
        super(UserManagementInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<SearchUsers>(_onSearchUsers);
    on<LoadUserDetails>(_onLoadUserDetails);
    on<BanUser>(_onBanUser);
    on<WarnUser>(_onWarnUser);
    on<UnbanUser>(_onUnbanUser);
    on<FilterUsers>(_onFilterUsers);
    on<LoadLinkedAccounts>(_onLoadLinkedAccounts);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UserManagementState> emit,
  ) async {
    try {
      emit(UserManagementLoading());

      final users = await _repository.getUsers(
        page: event.page,
        size: event.limit,
        search: event.searchQuery,
        status: event.statusFilter,
      );

      emit(UsersLoaded(
        users: users,
        searchQuery: event.searchQuery,
        statusFilter: event.statusFilter,
        currentPage: event.page,
        totalPages: 1,
        totalCount: users.length,
        hasMore: users.length >= event.limit,
      ));
    } catch (e) {
      emit(UserManagementError(message: 'Không thể tải danh sách người dùng: $e'));
    }
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<UserManagementState> emit,
  ) async {
    add(LoadUsers(searchQuery: event.query));
  }

  Future<void> _onLoadUserDetails(
    LoadUserDetails event,
    Emitter<UserManagementState> emit,
  ) async {
    try {
      emit(UserManagementLoading());

      final user = await _repository.getUserById(event.userId);

      // Activity from backend
      Map<String, dynamic>? activityData;
      try {
        activityData = await _repository.getUserActivity(event.userId);
      } catch (_) {
        // Non-critical, ignore failure
      }

      emit(UserDetailsLoaded(
        user: user,
        linkedAccounts: const [],
        additionalData: activityData,
      ));
    } catch (e) {
      emit(UserManagementError(message: 'Không thể tải thông tin người dùng: $e'));
    }
  }

  Future<void> _onBanUser(
    BanUser event,
    Emitter<UserManagementState> emit,
  ) async {
    try {
      emit(UserActionInProgress(userId: event.userId, actionType: 'ban'));

      await _repository.banUser(
        event.userId,
        event.banType,
        reason: event.reason,
        expiresAt: event.expiresAt,
      );

      emit(UserActionCompleted(
        userId: event.userId,
        actionType: 'ban',
        message: 'Đã ${event.banType.displayName.toLowerCase()} người dùng thành công',
      ));

      add(const LoadUsers());
    } catch (e) {
      emit(UserManagementError(message: 'Không thể khóa người dùng: $e'));
    }
  }

  Future<void> _onWarnUser(
    WarnUser event,
    Emitter<UserManagementState> emit,
  ) async {
    try {
      emit(UserActionInProgress(userId: event.userId, actionType: 'warn'));

      await _repository.warnUser(
        event.userId,
        reason: event.reason,
        message: event.message,
      );

      emit(UserActionCompleted(
        userId: event.userId,
        actionType: 'warn',
        message: 'Đã gửi cảnh cáo đến người dùng',
      ));

      add(const LoadUsers());
    } catch (e) {
      emit(UserManagementError(message: 'Không thể cảnh cáo người dùng: $e'));
    }
  }

  Future<void> _onUnbanUser(
    UnbanUser event,
    Emitter<UserManagementState> emit,
  ) async {
    try {
      emit(UserActionInProgress(userId: event.userId, actionType: 'unban'));

      await _repository.unbanUser(event.userId);

      emit(UserActionCompleted(
        userId: event.userId,
        actionType: 'unban',
        message: 'Đã mở khóa người dùng thành công',
      ));

      add(const LoadUsers());
    } catch (e) {
      emit(UserManagementError(message: 'Không thể mở khóa người dùng: $e'));
    }
  }

  Future<void> _onFilterUsers(
    FilterUsers event,
    Emitter<UserManagementState> emit,
  ) async {
    try {
      emit(UserManagementLoading());

      final users = await _repository.getUsers(
        status: event.status,
      );

      // Apply client-side risk score filtering if needed
      var filtered = users;
      if (event.minRiskScore != null) {
        filtered = filtered.where((u) => u.stats.riskScore >= event.minRiskScore!).toList();
      }
      if (event.maxRiskScore != null) {
        filtered = filtered.where((u) => u.stats.riskScore <= event.maxRiskScore!).toList();
      }
      if (event.joinedAfter != null) {
        filtered = filtered.where((u) => u.createdAt.isAfter(event.joinedAfter!)).toList();
      }
      if (event.joinedBefore != null) {
        filtered = filtered.where((u) => u.createdAt.isBefore(event.joinedBefore!)).toList();
      }

      emit(UsersLoaded(
        users: filtered,
        statusFilter: event.status,
        currentPage: 0,
        totalPages: 1,
        totalCount: filtered.length,
        hasMore: false,
      ));
    } catch (e) {
      emit(UserManagementError(message: 'Không thể lọc người dùng: $e'));
    }
  }

  Future<void> _onLoadLinkedAccounts(
    LoadLinkedAccounts event,
    Emitter<UserManagementState> emit,
  ) async {
    try {
      emit(UserManagementLoading());

      final linkedAccounts = await _repository.getLinkedAccounts(event.deviceId);

      emit(LinkedAccountsLoaded(
        deviceId: event.deviceId,
        linkedAccounts: linkedAccounts,
      ));
    } catch (e) {
      emit(UserManagementError(message: 'Không thể tải tài khoản liên kết: $e'));
    }
  }
}