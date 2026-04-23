import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

import '../../../../shared/services/auth_service.dart';
import '../../../../shared/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  
  const LoginRequested({required this.username, required this.password});
  
  @override
  List<Object> get props => [username, password];
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  
  const AuthFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  AuthBloc({required AuthRepository authRepository}) 
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final response = await _authRepository.login(event.username, event.password);
      
      // Backend trả về 'token' thay vì 'accessToken'
      final token = response['token'] as String?;
      
      if (token != null && token.isNotEmpty) {
        final authService = AuthService();
        // Lưu token vào cả accessToken và refreshToken (backend chưa hỗ trợ refresh token)
        await authService.saveTokens(token, token);
        
        emit(AuthSuccess());
      } else {
        emit(const AuthFailure('Phản hồi từ máy chủ không hợp lệ (thiếu token)'));
      }
    } on DioException catch (e) {
      // Handle DioException with user-friendly messages
      String errorMessage = _getErrorMessage(e);
      emit(AuthFailure(errorMessage));
    } catch (e) {
      emit(const AuthFailure('Đã xảy ra lỗi không xác định. Vui lòng thử lại.'));
    }
  }
  
  String _getErrorMessage(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final responseData = error.response!.data;
      
      // Try to extract error message from response
      String? serverMessage;
      if (responseData is Map) {
        serverMessage = responseData['message'] as String?;
      }
      
      switch (statusCode) {
        case 401:
          return 'Tên đăng nhập hoặc mật khẩu không đúng';
        case 403:
          return 'Tài khoản của bạn không có quyền truy cập';
        case 404:
          return 'Không tìm thấy dịch vụ xác thực';
        case 500:
          return 'Lỗi máy chủ. Vui lòng thử lại sau.';
        case 503:
          return 'Dịch vụ tạm thời không khả dụng. Vui lòng thử lại sau.';
        default:
          return serverMessage ?? 'Đăng nhập thất bại. Vui lòng thử lại.';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
               error.type == DioExceptionType.receiveTimeout) {
      return 'Kết nối quá chậm. Vui lòng kiểm tra mạng và thử lại.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
    } else {
      return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }
  
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final authService = AuthService();
      await authService.logout();
      // Optional: notify backend
      try { await _authRepository.logout(); } catch (_) {}
      
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure('Lỗi đăng xuất: ${e.toString()}'));
    }
  }
}