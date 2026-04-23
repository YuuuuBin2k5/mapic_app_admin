# 📱 MAPIC Manager App

Advanced admin dashboard for MAPIC social platform management built with Flutter.

## 🎯 Overview

MAPIC Manager is a comprehensive administrative application designed specifically for managing the MAPIC social media platform. It provides real-time monitoring, user management, content moderation, SOS emergency response, and advanced analytics capabilities.

## ✨ Key Features

### 📊 **Real-time Dashboard**
- Live metrics and KPIs
- Interactive heat map of Vietnam provinces
- System health monitoring
- Quick action panel

### 👥 **User Management**
- Advanced user search and filtering
- User behavior analytics
- Risk scoring system
- Bulk operations

### 📝 **Content Moderation**
- AI-powered content analysis
- Review queue management
- Batch approval/rejection
- Trending content detection

### 🚨 **SOS Emergency Monitoring**
- Real-time emergency alerts
- Live location tracking
- Emergency response coordination
- Safety analytics

### 📈 **Analytics & Reporting**
- Custom dashboard builder
- Predictive analytics
- Automated report generation
- Business intelligence tools

## 🏗️ Architecture

### Clean Architecture + BLoC Pattern
```
├── Presentation Layer (UI)
│   ├── Pages/Screens
│   ├── Widgets
│   └── BLoC (Business Logic)
├── Domain Layer (Business Logic)
│   ├── Entities
│   ├── Use Cases
│   └── Repository Interfaces
└── Data Layer (External)
    ├── Repository Implementations
    ├── Data Sources (API, Local)
    └── Models (DTOs)
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.2.0)
- Dart SDK
- Android Studio / VS Code
- MAPIC Backend API running

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mapic_manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure API endpoints**
   ```dart
   // lib/core/constants/api_constants.dart
   static const String baseUrl = 'http://your-api-url/api/admin';
   static const String wsBaseUrl = 'ws://your-api-url/admin/ws';
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (Chrome, Safari, Firefox)
- ✅ **Desktop** (Windows, macOS, Linux)

## 🎨 Design System

### Material Design 3
- **Primary Color**: MAPIC Blue (#4A90E2)
- **Success**: Green (#10B981)
- **Warning**: Orange (#F59E0B)
- **Danger**: Red (#EF4444)

### Typography
- **Font Family**: Inter
- **Responsive**: Adaptive text scaling
- **Accessibility**: WCAG 2.1 AA compliant

## 🔧 Configuration

### Environment Variables
Create `.env` file in the root directory:
```env
API_BASE_URL=http://localhost:8080/api/admin
WS_BASE_URL=ws://localhost:8080/admin/ws
ENVIRONMENT=development
```

### Permissions
The app requires the following permissions:
- **Internet**: API communication
- **Camera**: AR features (optional)
- **Microphone**: Voice commands (optional)
- **Location**: Emergency features

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widgets/

# Generate coverage
flutter test --coverage
```

### Test Structure
```
test/
├── unit/
│   ├── blocs/
│   ├── repositories/
│   └── services/
├── widget/
│   └── widgets/
└── integration/
    └── app_test.dart
```

## 📦 Build & Deployment

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

### Web
```bash
# Build for web
flutter build web --release
```

## 🔐 Security

### Authentication
- JWT token-based authentication
- Automatic token refresh
- Secure token storage
- Role-based access control

### Permissions
- **SUPER_ADMIN**: Full system access
- **ADMIN**: Most management features
- **MANAGER**: Dashboard and analytics
- **MODERATOR**: Content moderation only

## 📊 Performance

### Optimization
- Lazy loading of data
- Image caching
- WebSocket connection pooling
- Memory management

### Metrics
- App startup: < 3 seconds
- API response: < 500ms (95th percentile)
- Memory usage: < 150MB average
- Crash rate: < 0.1%

## 🛠️ Development

### Code Generation
```bash
# Generate all
flutter packages pub run build_runner build

# Watch mode
flutter packages pub run build_runner watch

# Clean and rebuild
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Debugging
- Flutter Inspector for UI debugging
- Network inspector for API calls
- BLoC observer for state management
- Logger for comprehensive logging

## 📚 Documentation

### API Documentation
- [Dashboard API](docs/api/dashboard.md)
- [User Management API](docs/api/users.md)
- [Content API](docs/api/content.md)
- [SOS API](docs/api/sos.md)

### Architecture Guides
- [Clean Architecture](docs/architecture/clean-architecture.md)
- [State Management](docs/architecture/state-management.md)
- [Dependency Injection](docs/architecture/dependency-injection.md)

## 🤝 Contributing

### Development Workflow
1. Create feature branch from `develop`
2. Make changes with clear commit messages
3. Write/update tests
4. Ensure all tests pass
5. Submit pull request

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` for linting
- Format code with `dart format`

## 📄 License

This project is proprietary software. All rights reserved.

**© 2024 MAPIC Development Team**

## 🆘 Support

### Issues
- Check existing [issues](https://github.com/your-repo/issues)
- Create new issue with detailed description
- Include logs and screenshots

### Contact
- **Email**: support@mapic.com
- **Documentation**: [docs.mapic.com](https://docs.mapic.com)
- **Status Page**: [status.mapic.com](https://status.mapic.com)

---

**Made with ❤️ using Flutter**# mapic_app_admin
