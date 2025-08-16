# 💰 Expenses Tracker Pro

A professional expense tracking app with analytics, budget management, and smart notifications. Track your spending, analyze patterns, and manage budgets with an intuitive and beautiful interface.

## ✨ Features

- **📊 Expense Tracking**: Easily add, edit, and categorize expenses
- **📈 Analytics Dashboard**: Visual insights into spending patterns
- **💰 Budget Management**: Set and monitor daily/weekly/monthly budgets
- **🔔 Smart Notifications**: Get reminders and budget alerts
- **🌙 Dark/Light Theme**: Beautiful themes for any preference
- **📱 Cross-Platform**: Works on Android, iOS, and Web
- **💾 Local Storage**: Secure local data storage with Hive
- **🔄 Offline First**: Works without internet connection

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.3.4 or higher
- Dart SDK 3.3.4 or higher
- Android Studio / VS Code
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/expenses_tracker.git
   cd expenses_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Building for Production

### Quick Production Build

#### Windows
```cmd
build_production.bat
```

#### Unix/Linux/macOS
```bash
chmod +x build_production.sh
./build_production.sh
```

### Manual Production Build

```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Build for Android (App Bundle - recommended for Play Store)
flutter build appbundle --release --target-platform android-arm64

# Build for Android (APK)
flutter build apk --release --target-platform android-arm64

# Build for Web
flutter build web --release

# Build for iOS (macOS only)
flutter build ios --release
```

### Build Outputs

- **Android**: `build/app/outputs/bundle/release/app-release.aab`
- **iOS**: `build/ios/archive/`
- **Web**: `build/web/`

## 📱 Platform Support

| Platform | Status | Min Version |
|----------|---------|-------------|
| Android  | ✅ Full | API 21+ |
| iOS      | ✅ Full | iOS 12.0+ |
| Web      | ✅ Full | Modern browsers |
| Windows  | 🔄 Partial | Windows 10+ |
| macOS    | 🔄 Partial | macOS 10.14+ |
| Linux    | 🔄 Partial | Ubuntu 18.04+ |

## 🏗️ Architecture

The app follows Clean Architecture principles with BLoC pattern for state management:

```
lib/
├── core/                    # Core functionality
│   ├── config/             # App configuration
│   ├── models/             # Data models
│   ├── services/           # Business services
│   ├── theme/              # App theming
│   └── utils/              # Utility functions
├── features/                # Feature modules
│   ├── budget/             # Budget management
│   ├── notifications/      # Notification system
│   ├── onboarding/         # User onboarding
│   ├── profile/            # User profile
│   └── track_expenses/     # Expense tracking
└── main.dart               # App entry point
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.3.4+
- **State Management**: BLoC (flutter_bloc)
- **Database**: Hive (local storage)
- **Charts**: fl_chart
- **Notifications**: flutter_local_notifications
- **UI Components**: Material Design 3
- **Build System**: Gradle (Android), Xcode (iOS)

## 📊 Performance

- **App Size**: < 50MB
- **Startup Time**: < 3 seconds
- **Memory Usage**: < 100MB
- **Battery Impact**: Minimal
- **Offline Support**: Full

## 🔒 Security

- Local data encryption
- Secure storage practices
- No external data transmission
- Privacy-first approach
- GDPR compliant

## 📋 Deployment Checklist

See [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) for a comprehensive guide to deploying the app to production.

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## 📈 Analytics & Monitoring

The app includes built-in support for:
- Crash reporting
- Performance monitoring
- User analytics
- Error tracking

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [Wiki](https://github.com/yourusername/expenses_tracker/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/expenses_tracker/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/expenses_tracker/discussions)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Hive team for the excellent local database
- All contributors and beta testers

---

**Made with ❤️ by the Expenses Tracker team**

*Version: 1.0.0 | Build: 2*
