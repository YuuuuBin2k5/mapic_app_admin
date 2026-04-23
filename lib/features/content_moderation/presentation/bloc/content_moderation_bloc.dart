import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/report_model.dart';
import '../../data/models/moderation_action_model.dart';
import '../../data/repositories/content_moderation_repository_impl.dart';
import '../../../../core/di/injection.dart';

// Events
abstract class ContentModerationEvent extends Equatable {
  const ContentModerationEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportQueue extends ContentModerationEvent {
  final ReportType? filterType;
  final ReportStatus? filterStatus;
  final ReportReason? filterReason;
  final String? searchQuery;
  final int page;
  final int size;

  const LoadReportQueue({
    this.filterType,
    this.filterStatus,
    this.filterReason,
    this.searchQuery,
    this.page = 0,
    this.size = 20,
  });

  @override
  List<Object?> get props => [filterType, filterStatus, filterReason, searchQuery, page, size];
}

class RefreshReportQueue extends ContentModerationEvent {}

class TakeAction extends ContentModerationEvent {
  final String reportId;
  final ModerationAction action;
  final String? reason;

  const TakeAction({
    required this.reportId,
    required this.action,
    this.reason,
  });

  @override
  List<Object?> get props => [reportId, action, reason];
}

class ViewReportDetails extends ContentModerationEvent {
  final String reportId;

  const ViewReportDetails(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

class FilterReports extends ContentModerationEvent {
  final ReportType? type;
  final ReportStatus? status;
  final ReportReason? reason;

  const FilterReports({
    this.type,
    this.status,
    this.reason,
  });

  @override
  List<Object?> get props => [type, status, reason];
}

// States
abstract class ContentModerationState extends Equatable {
  const ContentModerationState();

  @override
  List<Object?> get props => [];
}

class ContentModerationInitial extends ContentModerationState {}

class ContentModerationLoading extends ContentModerationState {}

class ReportQueueLoaded extends ContentModerationState {
  final List<ReportModel> reports;
  final ReportType? activeFilter;
  final ReportStatus? statusFilter;
  final String? searchQuery;
  final int totalCount;
  final int pendingCount;
  final int reviewedCount;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  const ReportQueueLoaded({
    required this.reports,
    this.activeFilter,
    this.statusFilter,
    this.searchQuery,
    required this.totalCount,
    required this.pendingCount,
    required this.reviewedCount,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  @override
  List<Object?> get props => [
    reports,
    activeFilter,
    statusFilter,
    searchQuery,
    totalCount,
    pendingCount,
    reviewedCount,
    totalElements,
    totalPages,
    currentPage,
    pageSize,
  ];
}

class ReportDetailsLoaded extends ContentModerationState {
  final ReportModel report;
  final List<ReportModel> relatedReports;
  final Map<String, dynamic>? contentDetails;

  const ReportDetailsLoaded({
    required this.report,
    required this.relatedReports,
    this.contentDetails,
  });

  @override
  List<Object?> get props => [report, relatedReports, contentDetails];
}

class ActionInProgress extends ContentModerationState {
  final String reportId;
  final ModerationAction action;

  const ActionInProgress({
    required this.reportId,
    required this.action,
  });

  @override
  List<Object?> get props => [reportId, action];
}

class ActionCompleted extends ContentModerationState {
  final String reportId;
  final ModerationAction action;
  final String message;

  const ActionCompleted({
    required this.reportId,
    required this.action,
    required this.message,
  });

  @override
  List<Object?> get props => [reportId, action, message];
}

class ContentModerationError extends ContentModerationState {
  final String message;
  final String? errorCode;

  const ContentModerationError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

// BLoC
class ContentModerationBloc extends Bloc<ContentModerationEvent, ContentModerationState> {
  final ContentModerationRepositoryImpl _repository;

  ContentModerationBloc() 
    : _repository = getIt<ContentModerationRepositoryImpl>(),
      super(ContentModerationInitial()) {
    on<LoadReportQueue>(_onLoadReportQueue);
    on<RefreshReportQueue>(_onRefreshReportQueue);
    on<TakeAction>(_onTakeAction);
    on<ViewReportDetails>(_onViewReportDetails);
    on<FilterReports>(_onFilterReports);
  }

  Future<void> _onLoadReportQueue(
    LoadReportQueue event,
    Emitter<ContentModerationState> emit,
  ) async {
    try {
      emit(ContentModerationLoading());
      
      final result = await _repository.getReportQueue(
        type: event.filterType,
        status: event.filterStatus,
        reason: event.filterReason,
        search: event.searchQuery,
        page: event.page,
        size: event.size,
      );
      
      final reports = result['content'] as List<ReportModel>;
      final totalElements = result['totalElements'] as int;
      final totalPages = result['totalPages'] as int;
      final pageNumber = result['pageNumber'] as int;
      final pageSize = result['pageSize'] as int;
      
      emit(ReportQueueLoaded(
        reports: reports,
        activeFilter: event.filterType,
        statusFilter: event.filterStatus,
        searchQuery: event.searchQuery,
        totalCount: reports.length,
        pendingCount: reports.where((r) => r.status == ReportStatus.pending).length,
        reviewedCount: reports.where((r) => r.status == ReportStatus.resolved).length,
        totalElements: totalElements,
        totalPages: totalPages,
        currentPage: pageNumber,
        pageSize: pageSize,
      ));
    } catch (e) {
      emit(ContentModerationError(message: 'Không thể tải danh sách báo cáo: $e'));
    }
  }

  Future<void> _onRefreshReportQueue(
    RefreshReportQueue event,
    Emitter<ContentModerationState> emit,
  ) async {
    try {
      final currentState = state;
      ReportType? filterType;
      ReportStatus? statusFilter;
      String? searchQuery;
      int currentPage = 0;
      int pageSize = 20;
      
      if (currentState is ReportQueueLoaded) {
        filterType = currentState.activeFilter;
        statusFilter = currentState.statusFilter;
        searchQuery = currentState.searchQuery;
        currentPage = currentState.currentPage;
        pageSize = currentState.pageSize;
      }
      
      final result = await _repository.getReportQueue(
        type: filterType,
        status: statusFilter,
        reason: null, // Default to null for refresh if not stored in state
        search: searchQuery,
        page: currentPage,
        size: pageSize,
      );
      
      final reports = result['content'] as List<ReportModel>;
      final totalElements = result['totalElements'] as int;
      final totalPages = result['totalPages'] as int;
      final pageNumber = result['pageNumber'] as int;
      
      emit(ReportQueueLoaded(
        reports: reports,
        activeFilter: filterType,
        statusFilter: statusFilter,
        searchQuery: searchQuery,
        totalCount: reports.length,
        pendingCount: reports.where((r) => r.status == ReportStatus.pending).length,
        reviewedCount: reports.where((r) => r.status == ReportStatus.resolved).length,
        totalElements: totalElements,
        totalPages: totalPages,
        currentPage: pageNumber,
        pageSize: pageSize,
      ));
    } catch (e) {
      emit(ContentModerationError(message: 'Không thể làm mới danh sách: $e'));
    }
  }

  Future<void> _onTakeAction(
    TakeAction event,
    Emitter<ContentModerationState> emit,
  ) async {
    try {
      emit(ActionInProgress(reportId: event.reportId, action: event.action));
      
      await _repository.moderateContent(
        event.reportId,
        event.action,
        reason: event.reason,
      );
      
      emit(ActionCompleted(
        reportId: event.reportId,
        action: event.action,
        message: 'Đã ${event.action.displayName.toLowerCase()} thành công',
      ));
      
      // Refresh the queue after action
      add(RefreshReportQueue());
    } catch (e) {
      emit(ContentModerationError(message: 'Không thể thực hiện hành động: $e'));
    }
  }

  Future<void> _onViewReportDetails(
    ViewReportDetails event,
    Emitter<ContentModerationState> emit,
  ) async {
    try {
      emit(ContentModerationLoading());
      
      final report = await _repository.getReportDetails(event.reportId);
      final result = await _repository.getReportQueue(page: 0, size: 3);
      final relatedReports = result['content'] as List<ReportModel>;
      
      emit(ReportDetailsLoaded(
        report: report,
        relatedReports: relatedReports,
        contentDetails: {
          'fullImageUrl': report.imageUrl,
          'originalText': report.contentPreview,
          'metadata': {
            'location': 'Hà Nội',
            'timestamp': report.createdAt.toIso8601String(),
          },
        },
      ));
    } catch (e) {
      emit(ContentModerationError(message: 'Không thể tải chi tiết báo cáo: $e'));
    }
  }

  Future<void> _onFilterReports(
    FilterReports event,
    Emitter<ContentModerationState> emit,
  ) async {
    try {
      emit(ContentModerationLoading());
      
      final result = await _repository.getReportQueue(
        type: event.type,
        status: event.status,
        reason: event.reason,
        page: 0,
        size: 20,
      );
      
      final reports = result['content'] as List<ReportModel>;
      final totalElements = result['totalElements'] as int;
      final totalPages = result['totalPages'] as int;
      final pageNumber = result['pageNumber'] as int;
      final pageSize = result['pageSize'] as int;
      
      emit(ReportQueueLoaded(
        reports: reports,
        activeFilter: event.type,
        statusFilter: event.status,
        totalCount: reports.length,
        pendingCount: reports.where((r) => r.status == ReportStatus.pending).length,
        reviewedCount: reports.where((r) => r.status == ReportStatus.resolved).length,
        totalElements: totalElements,
        totalPages: totalPages,
        currentPage: pageNumber,
        pageSize: pageSize,
      ));
    } catch (e) {
      emit(ContentModerationError(message: 'Không thể lọc báo cáo: $e'));
    }
  }
}