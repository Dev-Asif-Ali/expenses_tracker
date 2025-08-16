class ProductionConfig {
  // App configuration
  static const String appName = 'Expenses Tracker Pro';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 2;
  
  // Database configuration
  static const String databaseName = 'Expenses_Database';
  static const String userProfileBoxName = 'UserProfile';
  
  // Notification configuration
  static const String notificationChannelId = 'expenses_tracker_channel';
  static const String notificationChannelName = 'Expenses Tracker';
  static const String notificationChannelDescription = 'Notifications for expenses tracking and budget alerts';
  
  // Performance settings
  static const int splashScreenDelay = 3; // seconds
  static const int maxExpenseItems = 10000; // Maximum items to keep in memory
  
  // Feature flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;
  static const bool enableNotifications = true;
  
  // Cache settings
  static const int maxCacheSize = 50; // MB
  static const Duration cacheExpiry = Duration(days: 7);
  
  // Security settings
  static const bool enableDataEncryption = true;
  static const bool enableSecureStorage = true;
  
  // Debug settings (disabled in production)
  static const bool enableDebugLogs = false;
  static const bool enablePerformanceOverlay = false;
  static const bool enableSemanticsDebugger = false;
}
