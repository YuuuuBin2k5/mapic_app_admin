# 🔧 MAPIC Manager App - Technical Specifications

## 📋 Dependencies & Packages

### Core Flutter Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # UI & Design
  material_color_utilities: ^0.8.0
  flutter_animate: ^4.2.0
  shimmer: ^3.0.0
  
  # Charts & Visualization
  fl_chart: ^0.65.0
  syncfusion_flutter_charts: ^23.2.7
  
  # Maps & Location
  maplibre_gl: ^0.18.0
  geolocator: ^10.1.0
  
  # Network & API
  dio: ^5.4.0
  retrofit: ^4.0.3
  web_socket_channel: ^2.4.0
  
  # Storage & Cache
  hive: ^2.2.3
  shared_preferences: ^2.2.2
  
  # Utils
  intl: ^0.19.0
  logger: ^2.0.2
  permission_handler: ^11.1.0

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.7
  retrofit_generator: ^8.0.4
  hive_generator: ^2.0.1
  
  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  bloc_test: ^9.1.5
```

## 🏗️ Architecture Pattern

### Clean Architecture + BLoC Pattern
```
Presentation Layer (UI)
├── Pages/Screens
├── Widgets
└── BLoC (Business Logic Components)

Domain Layer (Business Logic)
├── Entities
├── Use Cases
└── Repository Interfaces

Data Layer (External)
├── Repository Implementations
├── Data Sources (API, Local)
└── Models (DTOs)
```

## 📊 Data Models

### Dashboard Models
```dart
class DashboardMetrics {
  final int totalUsers;
  final int activeMoments;
  final double engagementRate;
  final int activeSosAlerts;
  final List<ProvinceActivity> provinceData;
  
  const DashboardMetrics({
    required this.totalUsers,
    required this.activeMoments,
    required this.engagementRate,
    required this.activeSosAlerts,
    required this.provinceData,
  });
}

class ProvinceActivity {
  final String provinceName;
  final int userCount;
  final int momentCount;
  final double latitude;
  final double longitude;
  
  const ProvinceActivity({
    required this.provinceName,
    required this.userCount,
    required this.momentCount,
    required this.latitude,
    required this.longitude,
  });
}
```

### User Management Models
```dart
class UserProfile {
  final String id;
  final String username;
  final String name;
  final String email;
  final String? avatarUrl;
  final UserStatus status;
  final DateTime joinDate;
  final UserActivity activity;
  final RiskScore riskScore;
  
  const UserProfile({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.status,
    required this.joinDate,
    required this.activity,
    required this.riskScore,
  });
}

class UserActivity {
  final int totalMoments;
  final int totalComments;
  final int totalReactions;
  final DateTime lastActive;
  final List<ActivityEvent> recentEvents;
  
  const UserActivity({
    required this.totalMoments,
    required this.totalComments,
    required this.totalReactions,
    required this.lastActive,
    required this.recentEvents,
  });
}

enum RiskLevel { low, medium, high, critical }

class RiskScore {
  final RiskLevel level;
  final double score; // 0.0 - 1.0
  final List<String> reasons;
  
  const RiskScore({
    required this.level,
    required this.score,
    required this.reasons,
  });
}
```

### SOS Monitoring Models
```dart
class SosAlert {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final double latitude;
  final double longitude;
  final DateTime triggeredAt;
  final SosStatus status;
  final List<SosRecipient> recipients;
  final List<LocationUpdate> locationHistory;
  
  const SosAlert({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.latitude,
    required this.longitude,
    required this.triggeredAt,
    required this.status,
    required this.recipients,
    required this.locationHistory,
  });
}

class LocationUpdate {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double accuracy;
  
  const LocationUpdate({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.accuracy,
  });
}

enum SosStatus { active, resolved, expired }
```

## 🔄 State Management with BLoC

### Dashboard BLoC
```dart
// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
}

class LoadDashboardData extends DashboardEvent {
  @override
  List<Object> get props => [];
}

class RefreshDashboardData extends DashboardEvent {
  @override
  List<Object> get props => [];
}

class FilterDashboardByDateRange extends DashboardEvent {
  final DateRange dateRange;
  
  const FilterDashboardByDateRange(this.dateRange);
  
  @override
  List<Object> get props => [dateRange];
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  @override
  List<Object> get props => [];
}

class DashboardLoading extends DashboardState {
  @override
  List<Object> get props => [];
}

class DashboardLoaded extends DashboardState {
  final DashboardMetrics metrics;
  final List<TrendData> trends;
  
  const DashboardLoaded({
    required this.metrics,
    required this.trends,
  });
  
  @override
  List<Object> get props => [metrics, trends];
}

class DashboardError extends DashboardState {
  final String message;
  
  const DashboardError(this.message);
  
  @override
  List<Object> get props => [message];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardMetrics _getDashboardMetrics;
  final GetTrendData _getTrendData;
  
  DashboardBloc({
    required GetDashboardMetrics getDashboardMetrics,
    required GetTrendData getTrendData,
  }) : _getDashboardMetrics = getDashboardMetrics,
       _getTrendData = getTrendData,
       super(DashboardInitial()) {
    
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<FilterDashboardByDateRange>(_onFilterByDateRange);
  }
  
  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    
    try {
      final metrics = await _getDashboardMetrics();
      final trends = await _getTrendData();
      
      emit(DashboardLoaded(
        metrics: metrics,
        trends: trends,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
```

## 🌐 API Integration

### API Service Layer
```dart
@RestApi(baseUrl: "https://api.mapic.com/admin/")
abstract class MapicManagerApi {
  factory MapicManagerApi(Dio dio, {String baseUrl}) = _MapicManagerApi;
  
  // Dashboard APIs
  @GET("/dashboard/metrics")
  Future<DashboardMetrics> getDashboardMetrics();
  
  @GET("/dashboard/trends")
  Future<List<TrendData>> getTrendData(
    @Query("startDate") String startDate,
    @Query("endDate") String endDate,
  );
  
  // User Management APIs
  @GET("/users")
  Future<PaginatedResponse<UserProfile>> getUsers(
    @Query("page") int page,
    @Query("size") int size,
    @Query("search") String? search,
    @Query("status") String? status,
  );
  
  @GET("/users/{id}")
  Future<UserProfile> getUserById(@Path("id") String id);
  
  @PUT("/users/{id}/status")
  Future<void> updateUserStatus(
    @Path("id") String id,
    @Body() UserStatusUpdate update,
  );
  
  // Content Management APIs
  @GET("/content/queue")
  Future<List<ContentReviewItem>> getContentReviewQueue();
  
  @POST("/content/{id}/approve")
  Future<void> approveContent(@Path("id") String id);
  
  @POST("/content/{id}/reject")
  Future<void> rejectContent(
    @Path("id") String id,
    @Body() ContentRejectionReason reason,
  );
  
  // SOS Monitoring APIs
  @GET("/sos/active")
  Future<List<SosAlert>> getActiveSosAlerts();
  
  @GET("/sos/{id}/details")
  Future<SosAlert> getSosAlertDetails(@Path("id") String id);
  
  @POST("/sos/{id}/respond")
  Future<void> respondToSosAlert(
    @Path("id") String id,
    @Body() EmergencyResponse response,
  );
}
```

### WebSocket Service
```dart
class WebSocketService {
  late WebSocketChannel _channel;
  final StreamController<dynamic> _messageController = StreamController.broadcast();
  
  Stream<dynamic> get messages => _messageController.stream;
  
  Future<void> connect(String token) async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://api.mapic.com/admin/ws'),
        protocols: ['Bearer', token],
      );
      
      _channel.stream.listen(
        (message) {
          final data = jsonDecode(message);
          _messageController.add(data);
        },
        onError: (error) {
          Logger().e('WebSocket error: $error');
        },
      );
    } catch (e) {
      Logger().e('Failed to connect WebSocket: $e');
    }
  }
  
  void subscribeToSosAlerts() {
    _channel.sink.add(jsonEncode({
      'action': 'subscribe',
      'channel': 'sos_alerts'
    }));
  }
  
  void subscribeToUserActivity() {
    _channel.sink.add(jsonEncode({
      'action': 'subscribe',
      'channel': 'user_activity'
    }));
  }
  
  void disconnect() {
    _channel.sink.close();
    _messageController.close();
  }
}
```

## 🎨 Custom Widgets

### Animated Metric Card
```dart
class AnimatedMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  
  const AnimatedMetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().scale(),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Interactive Heat Map
```dart
class InteractiveHeatMap extends StatefulWidget {
  final List<ProvinceActivity> data;
  final Function(ProvinceActivity)? onProvinceSelected;
  
  const InteractiveHeatMap({
    Key? key,
    required this.data,
    this.onProvinceSelected,
  }) : super(key: key);
  
  @override
  State<InteractiveHeatMap> createState() => _InteractiveHeatMapState();
}

class _InteractiveHeatMapState extends State<InteractiveHeatMap> {
  MapLibreMapController? _mapController;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: MapLibreMap(
        onMapCreated: (MapLibreMapController controller) {
          _mapController = controller;
          _addHeatMapLayer();
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(16.0583, 108.2772), // Vietnam center
          zoom: 5.5,
        ),
        onMapClick: (point, latLng) {
          _handleMapClick(latLng);
        },
      ),
    );
  }
  
  void _addHeatMapLayer() {
    // Add heat map visualization logic
    for (final province in widget.data) {
      _mapController?.addCircle(
        CircleOptions(
          geometry: LatLng(province.latitude, province.longitude),
          circleRadius: _calculateRadius(province.userCount),
          circleColor: _getHeatColor(province.userCount),
          circleOpacity: 0.7,
        ),
      );
    }
  }
  
  double _calculateRadius(int userCount) {
    return (userCount / 1000) * 20 + 5; // Scale radius based on user count
  }
  
  String _getHeatColor(int userCount) {
    if (userCount > 1000) return "#FF0000"; // Red for high activity
    if (userCount > 500) return "#FF8000";  // Orange for medium activity
    return "#00FF00"; // Green for low activity
  }
  
  void _handleMapClick(LatLng latLng) {
    // Find nearest province and trigger callback
    final nearestProvince = _findNearestProvince(latLng);
    if (nearestProvince != null) {
      widget.onProvinceSelected?.call(nearestProvince);
    }
  }
}
```

## 🔐 Security Implementation

### JWT Token Management
```dart
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  Future<void> saveTokens(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;
    
    try {
      final payload = JwtDecoder.decode(token);
      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      return exp > now;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
```

### API Interceptor for Authentication
```dart
class AuthInterceptor extends Interceptor {
  final AuthService _authService;
  
  AuthInterceptor(this._authService);
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the original request
        final response = await _retry(err.requestOptions);
        handler.resolve(response);
        return;
      } else {
        // Refresh failed, logout user
        await _authService.logout();
        // Navigate to login screen
      }
    }
    handler.next(err);
  }
}
```

## 📱 Responsive Design Implementation

### Breakpoint System
```dart
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;
      
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;
      
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.mobile) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

## 🧪 Testing Strategy

### Unit Tests
```dart
void main() {
  group('DashboardBloc', () {
    late DashboardBloc dashboardBloc;
    late MockGetDashboardMetrics mockGetDashboardMetrics;
    
    setUp(() {
      mockGetDashboardMetrics = MockGetDashboardMetrics();
      dashboardBloc = DashboardBloc(
        getDashboardMetrics: mockGetDashboardMetrics,
      );
    });
    
    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardLoading, DashboardLoaded] when LoadDashboardData is added',
      build: () {
        when(() => mockGetDashboardMetrics())
            .thenAnswer((_) async => mockDashboardMetrics);
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(LoadDashboardData()),
      expect: () => [
        DashboardLoading(),
        DashboardLoaded(metrics: mockDashboardMetrics, trends: []),
      ],
    );
  });
}
```

### Widget Tests
```dart
void main() {
  group('AnimatedMetricCard', () {
    testWidgets('displays correct title and value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedMetricCard(
              title: 'Total Users',
              value: '1,234',
              subtitle: '+12% from last month',
              icon: Icons.people,
              color: Colors.blue,
            ),
          ),
        ),
      );
      
      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('1,234'), findsOneWidget);
      expect(find.text('+12% from last month'), findsOneWidget);
    });
  });
}
```

---

*Technical specifications được thiết kế để đảm bảo MAPIC Manager App có kiến trúc vững chắc, hiệu suất cao và dễ dàng bảo trì.*