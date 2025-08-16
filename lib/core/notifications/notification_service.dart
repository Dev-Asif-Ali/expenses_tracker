import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize settings
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(settings);

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request Android permissions
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
    
    // Request iOS permissions
    final iosImplementation = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expenses_tracker_channel',
      'Expenses Tracker',
      channelDescription: 'Notifications for expenses tracking and budget alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Schedule notification for specific time
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expenses_tracker_channel',
      'Expenses Tracker',
      channelDescription: 'Notifications for expenses tracking and budget alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Schedule recurring notification
  Future<void> scheduleRecurringNotification({
    required String title,
    required String body,
    required DateTime startDate,
    required String recurringPeriod,
    String? payload,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expenses_tracker_channel',
      'Expenses Tracker',
      channelDescription: 'Notifications for expenses tracking and budget alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Calculate next occurrence based on recurring period
    DateTime nextOccurrence = _getNextOccurrence(startDate, recurringPeriod);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(nextOccurrence, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: _getDateTimeComponents(recurringPeriod),
    );
  }

  DateTime _getNextOccurrence(DateTime startDate, String recurringPeriod) {
    final now = DateTime.now();
    DateTime next = startDate;

    while (next.isBefore(now)) {
      switch (recurringPeriod) {
        case 'daily':
          next = next.add(const Duration(days: 1));
          break;
        case 'weekly':
          next = next.add(const Duration(days: 7));
          break;
        case 'monthly':
          next = DateTime(next.year, next.month + 1, next.day);
          break;
        case 'yearly':
          next = DateTime(next.year + 1, next.month, next.day);
          break;
        default:
          next = next.add(const Duration(days: 1));
      }
    }

    return next;
  }

  DateTimeComponents? _getDateTimeComponents(String recurringPeriod) {
    switch (recurringPeriod) {
      case 'daily':
        return DateTimeComponents.time;
      case 'weekly':
        return DateTimeComponents.dayOfWeekAndTime;
      case 'monthly':
        return DateTimeComponents.dayOfMonthAndTime;
      case 'yearly':
        return DateTimeComponents.dayOfMonthAndTime; // Using dayOfMonthAndTime as fallback
      default:
        return null;
    }
  }

  // Budget-related notifications
  Future<void> showBudgetAlert({
    required String budgetName,
    required double spent,
    required double limit,
    required double remaining,
  }) async {
    final percentage = (spent / limit) * 100;
    String title, body;

    if (percentage >= 90) {
      title = '🚨 Budget Warning!';
      body = 'You\'ve spent ${percentage.toStringAsFixed(1)}% of your $budgetName budget. Only \$${remaining.toStringAsFixed(2)} remaining.';
    } else if (percentage >= 75) {
      title = '⚠️ Budget Alert';
      body = 'You\'ve spent ${percentage.toStringAsFixed(1)}% of your $budgetName budget. \$${remaining.toStringAsFixed(2)} remaining.';
    } else {
      title = '💰 Budget Update';
      body = 'You\'ve spent ${percentage.toStringAsFixed(1)}% of your $budgetName budget. \$${remaining.toStringAsFixed(2)} remaining.';
    }

    await showNotification(title: title, body: body);
  }

  // Spending reminder notifications
  Future<void> showSpendingReminder({
    required String message,
    DateTime? scheduledTime,
  }) async {
    if (scheduledTime != null) {
      await scheduleNotification(
        title: '💡 Spending Reminder',
        body: message,
        scheduledDate: scheduledTime,
      );
    } else {
      await showNotification(
        title: '💡 Spending Reminder',
        body: message,
      );
    }
  }

  // Recurring expense notifications
  Future<void> showRecurringExpenseReminder({
    required ExpensesItem expense,
    DateTime? scheduledTime,
  }) async {
    final message = 'Don\'t forget to record your recurring ${expense.name} expense (\$${expense.amount.toStringAsFixed(2)})';
    
    if (scheduledTime != null) {
      await scheduleNotification(
        title: '🔄 Recurring Expense',
        body: message,
        scheduledDate: scheduledTime,
      );
    } else {
      await showNotification(
        title: '🔄 Recurring Expense',
        body: message,
      );
    }
  }

  // Weekly spending summary
  Future<void> showWeeklySummary({
    required double totalSpent,
    required double weeklyBudget,
    required List<ExpensesItem> topExpenses,
  }) async {
    final percentage = weeklyBudget > 0 ? (totalSpent / weeklyBudget) * 100 : 0;
    final remaining = weeklyBudget - totalSpent;
    
    String title, body;
    
    if (percentage >= 100) {
      title = '🚨 Weekly Budget Exceeded!';
      body = 'You\'ve spent \$${totalSpent.toStringAsFixed(2)} this week, exceeding your budget by \$${remaining.abs().toStringAsFixed(2)}.';
    } else if (percentage >= 80) {
      title = '⚠️ Weekly Budget Alert';
      body = 'You\'ve spent \$${totalSpent.toStringAsFixed(2)} this week (${percentage.toStringAsFixed(1)}% of budget). \$${remaining.toStringAsFixed(2)} remaining.';
    } else {
      title = '📊 Weekly Summary';
      body = 'You\'ve spent \$${totalSpent.toStringAsFixed(2)} this week (${percentage.toStringAsFixed(1)}% of budget). \$${remaining.toStringAsFixed(2)} remaining.';
    }

    // Add top expense info if available
    if (topExpenses.isNotEmpty) {
      body += '\n\nTop expense: ${topExpenses.first.name} (\$${topExpenses.first.amount.toStringAsFixed(2)})';
    }

    await showNotification(title: title, body: body);
  }

  // Goal achievement notification
  Future<void> showGoalAchievement({
    required String goalName,
    required double targetAmount,
    required double currentAmount,
  }) async {
    final percentage = (currentAmount / targetAmount) * 100;
    
    if (percentage >= 100) {
      await showNotification(
        title: '🎉 Goal Achieved!',
        body: 'Congratulations! You\'ve reached your $goalName goal of \$${targetAmount.toStringAsFixed(2)}!',
      );
    } else if (percentage >= 75) {
      await showNotification(
        title: '🎯 Goal Progress',
        body: 'Great progress! You\'re ${percentage.toStringAsFixed(1)}% towards your $goalName goal. \$${(targetAmount - currentAmount).toStringAsFixed(2)} to go!',
      );
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
