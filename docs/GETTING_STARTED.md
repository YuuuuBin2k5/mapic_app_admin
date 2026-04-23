# 🚀 Getting Started with MAPIC Manager

This guide will help you set up and run the MAPIC Manager app on your development environment.

## 📋 Prerequisites

### Required Software
- **Flutter SDK** (>=3.2.0) - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (included with Flutter)
- **Git** - [Install Git](https://git-scm.com/downloads)

### Development Environment
Choose one of the following:
- **Android Studio** (recommended) - [Download](https://developer.android.com/studio)
- **VS Code** with Flutter extension - [Download](https://code.visualstudio.com/)
- **IntelliJ IDEA** with Flutter plugin

### Platform-Specific Requirements

#### For Android Development
- **Android SDK** (API level 21 or higher)
- **Android Emulator** or physical Android device
- **Java Development Kit (JDK)** 8 or higher

#### For iOS Development (macOS only)
- **Xcode** (latest version)
- **iOS Simulator** or physical iOS device
- **CocoaPods** - `sudo gem install cocoapods`

#### For Web Development
- **Chrome** browser (for debugging)

## 🛠️ Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd mapic_manager
```

### 2. Verify Flutter Installation
```bash
flutter doctor
```
Ensure all checkmarks are green. Fix any issues before proceeding.

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Generate Code
```bash
flutter packages pub run build_runner build
```

### 5. Configure Environment

#### Create Environment File
Create a `.env` file in the root directory:
```env
# API Configuration
API_BASE_URL=http://localhost:8080/api/admin
WS_BASE_URL=ws://localhost:8080/admin/ws

# Environment
ENVIRONMENT=development
DEBUG_MODE=true

# Features
ENABLE_AR_FEATURES=false
ENABLE_VOICE_COMMANDS=false
```

#### Update API Constants
Edit `lib/core/constants/api_constants.dart`:
```dart
class ApiConstants {
  static const String baseUrl = 'http://your-backend-url/api/admin';
  static const String wsBaseUrl = 'ws://your-backend-url/admin/ws';
  // ... rest of the configuration
}
```

## 🏃‍♂️ Running the App

### Development Mode
```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Run with hot reload (default)
flutter run --hot

# Run in debug mode with verbose logging
flutter run --debug --verbose
```

### Platform-Specific Commands

#### Android
```bash
# Run on Android emulator
flutter run -d android

# Build APK for testing
flutter build apk --debug
```

#### iOS (macOS only)
```bash
# Run on iOS simulator
flutter run -d ios

# Build for iOS device
flutter build ios --debug
```

#### Web
```bash
# Run on web browser
flutter run -d chrome

# Build for web
flutter build web
```

## 🔧 Development Setup

### IDE Configuration

#### VS Code
Install these extensions:
- Flutter
- Dart
- Bracket Pair Colorizer
- GitLens
- Error Lens

#### Android Studio
Install these plugins:
- Flutter
- Dart
- Rainbow Brackets
- GitToolBox

### Debugging Setup

#### Enable Debug Mode
```dart
// In main.dart
void main() {
  // Enable debug mode
  if (kDebugMode) {
    Logger.level = Level.debug;
  }
  
  runApp(MyApp());
}
```

#### Debug Configuration
Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "mapic_manager",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--flavor", "development"]
    },
    {
      "name": "mapic_manager (profile mode)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile",
      "program": "lib/main.dart"
    }
  ]
}
```

## 🧪 Testing Setup

### Run Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/auth_test.dart

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Test Configuration
Create `test/test_config.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock services setup
  // ...
}
```

## 🔐 Authentication Setup

### Backend Connection
Ensure your MAPIC backend is running and accessible:

1. **Start MAPIC Backend**
   ```bash
   cd ../mapic_api
   ./mvnw spring-boot:run
   ```

2. **Verify API Connection**
   ```bash
   curl http://localhost:8080/api/admin/health
   ```

3. **Test Authentication**
   Use these default admin credentials:
   - Username: `admin`
   - Password: `admin123`

### Create Test Admin Account
If no admin account exists, create one via backend:
```sql
INSERT INTO admins (username, password, status, created_at) 
VALUES ('admin', '$2a$10$encrypted_password', 'ACTIVE', NOW());
```

## 📱 Device Setup

### Android Device
1. Enable Developer Options
2. Enable USB Debugging
3. Connect device via USB
4. Accept debugging permission

### iOS Device (macOS only)
1. Connect device via USB
2. Trust the computer
3. Enable Developer Mode in Settings

### Emulator Setup

#### Android Emulator
```bash
# List available AVDs
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator-id>
```

#### iOS Simulator (macOS only)
```bash
# Open iOS Simulator
open -a Simulator

# List available simulators
xcrun simctl list devices
```

## 🚨 Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues
```bash
# Fix Android license issues
flutter doctor --android-licenses

# Update Flutter
flutter upgrade

# Clean and rebuild
flutter clean && flutter pub get
```

#### 2. Build Errors
```bash
# Clean build cache
flutter clean

# Reset pub cache
flutter pub cache repair

# Regenerate code
flutter packages pub run build_runner clean
flutter packages pub run build_runner build
```

#### 3. API Connection Issues
- Check backend is running on correct port
- Verify API_BASE_URL in configuration
- Check network connectivity
- Verify CORS settings on backend

#### 4. WebSocket Connection Issues
- Ensure WebSocket endpoint is correct
- Check authentication token
- Verify network allows WebSocket connections

### Debug Commands
```bash
# Check Flutter installation
flutter doctor -v

# Analyze code for issues
flutter analyze

# Check for outdated packages
flutter pub outdated

# Verbose logging
flutter run --verbose

# Performance profiling
flutter run --profile
```

## 📚 Next Steps

1. **Explore the Codebase**
   - Review `lib/` directory structure
   - Understand the Clean Architecture pattern
   - Check out the BLoC state management

2. **Read Documentation**
   - [Architecture Guide](docs/ARCHITECTURE.md)
   - [API Documentation](docs/API.md)
   - [UI/UX Guidelines](docs/UI_DESIGN.md)

3. **Start Development**
   - Create a new feature branch
   - Follow the development workflow
   - Write tests for new features

## 🆘 Getting Help

- **Documentation**: Check the `docs/` directory
- **Issues**: Create an issue on the repository
- **Team Chat**: Contact the development team
- **Stack Overflow**: Tag questions with `flutter` and `mapic`

---

**Happy Coding! 🎉**