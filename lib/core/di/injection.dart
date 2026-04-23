import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/mapic_api_service.dart';
import '../../shared/services/mapic_websocket_service.dart';
import '../../shared/repositories/auth_repository.dart';
import '../../shared/repositories/dashboard_repository.dart';
import '../../features/content_moderation/data/repositories/content_moderation_repository_impl.dart';
import '../../features/user_management/data/repositories/user_management_repository_impl.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Register Dio with optimized settings for mobile
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add minimal interceptors for better performance
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) {},
    ));
    
    return dio;
  });
  
  // Register Core Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<MapicApiService>(() => MapicApiService());
  
  // Register WebSocket service
  getIt.registerLazySingleton<MapicWebSocketService>(() => MapicWebSocketService());
  
  // Register Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<MapicApiService>()),
  );
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepository(getIt<MapicApiService>()),
  );
  
  // Register Feature Repositories
  getIt.registerLazySingleton<ContentModerationRepositoryImpl>(
    () => ContentModerationRepositoryImpl(getIt<MapicApiService>()),
  );
  
  getIt.registerLazySingleton<UserManagementRepositoryImpl>(
    () => UserManagementRepositoryImpl(getIt<MapicApiService>()),
  );
  
  getIt.registerLazySingleton<NotificationsRepositoryImpl>(
    () => NotificationsRepositoryImpl(getIt<MapicApiService>()),
  );
}