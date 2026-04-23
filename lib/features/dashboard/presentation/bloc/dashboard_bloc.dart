import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/repositories/dashboard_repository.dart';
import '../../../../core/di/injection.dart';

// ═══════════════════════════════════════════════════════ Events

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  const LoadDashboardData();
}

class RefreshDashboardData extends DashboardEvent {
  const RefreshDashboardData();
}

// ═══════════════════════════════════════════════════════ States

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final Map<String, dynamic> data;

  const DashboardLoaded(this.data);

  // Convenience getters
  int get totalUsers => data['totalUsers'] as int? ?? 0;
  int get activeUsers => data['activeUsers'] as int? ?? 0;
  int get pendingReports => data['pendingReports'] as int? ?? 0;
  int get totalMoments => data['totalMoments'] as int? ?? 0;
  int get momentsToday => data['momentsToday'] as int? ?? 0;
  int get resolvedReportsToday => data['resolvedReportsToday'] as int? ?? 0;

  @override
  List<Object> get props => [data];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}

// ═══════════════════════════════════════════════════════ BLoC

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc()
      : _repository = getIt<DashboardRepository>(),
        super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final metrics = await _repository.getDashboardMetrics();
      emit(DashboardLoaded(metrics));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final metrics = await _repository.getDashboardMetrics();
      emit(DashboardLoaded(metrics));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}