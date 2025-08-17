import 'package:expenses_tracker/core/notifications/notification_service.dart';
import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';
import 'package:expenses_tracker/core/services/user_profile_service.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final NotificationService _notificationService = NotificationService();
  final UserProfileService _userProfileService = UserProfileService();

  String _fmt(double amount) {
    final profile = _userProfileService.currentProfile;
    if (profile != null) return profile.formatAmount(amount);
    return '\$' + amount.toStringAsFixed(2);
  }

  // Initialize notifications
  Future<void> initialize() async {
    await _notificationService.initialize();
  }

  // Handle new expense added
  Future<void> onExpenseAdded(ExpensesItem expense) async {
    // Show confirmation notification
    await _notificationService.showNotification(
      title: '✅ Expense Added',
      body: '${expense.name} - ' + _fmt(expense.amount) + ' has been recorded.',
    );

    // If it's a recurring expense, schedule the next reminder
    if (expense.isRecurring && expense.recurringPeriod != null) {
      await _scheduleRecurringExpenseReminder(expense);
    }

    // Check if this expense might affect any budgets
    await _checkBudgetAlerts(expense);
  }

  // Handle expense updated
  Future<void> onExpenseUpdated(ExpensesItem expense) async {
    await _notificationService.showNotification(
      title: '✏️ Expense Updated',
      body: '${expense.name} has been updated to ' + _fmt(expense.amount) + '.',
    );

    // Re-schedule recurring expense reminder if needed
    if (expense.isRecurring && expense.recurringPeriod != null) {
      await _scheduleRecurringExpenseReminder(expense);
    }
  }

  // Handle expense deleted
  Future<void> onExpenseDeleted(ExpensesItem expense) async {
    await _notificationService.showNotification(
      title: '🗑️ Expense Deleted',
      body: '${expense.name} has been removed from your records.',
    );

    // Cancel any scheduled reminders for this expense
    await _notificationService.cancelNotification(expense.hashCode);
  }

  // Schedule recurring expense reminder
  Future<void> _scheduleRecurringExpenseReminder(ExpensesItem expense) async {
    // Calculate next occurrence based on recurring period
    DateTime nextOccurrence = _calculateNextOccurrence(expense.dateTime, expense.recurringPeriod!);
    
    // Schedule reminder for 1 day before the next occurrence
    DateTime reminderTime = nextOccurrence.subtract(const Duration(days: 1));
    
    await _notificationService.scheduleNotification(
      title: '🔄 Recurring Expense Reminder',
      body: 'Don\'t forget to record your ${expense.name} expense (' + _fmt(expense.amount) + ') tomorrow.',
      scheduledDate: reminderTime,
      id: expense.hashCode,
    );
  }

  // Calculate next occurrence for recurring expenses
  DateTime _calculateNextOccurrence(DateTime startDate, String recurringPeriod) {
    DateTime next = startDate;
    final now = DateTime.now();

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

  // Check budget alerts
  Future<void> _checkBudgetAlerts(ExpensesItem expense) async {
    // This would integrate with your budget system
    // For now, we'll show a general spending alert
    await _showSpendingInsight(expense);
  }

  // Show spending insight
  Future<void> _showSpendingInsight(ExpensesItem expense) async {
    String insight = '';
    
    // Provide insights based on category and amount
    switch (expense.category) {
      case ExpenseCategory.food:
        if (expense.amount > 50) {
          insight = 'This is a significant food expense. Consider meal planning to save money.';
        }
        break;
      case ExpenseCategory.transport:
        if (expense.amount > 30) {
          insight = 'Transport costs can add up quickly. Consider carpooling or public transport.';
        }
        break;
      case ExpenseCategory.entertainment:
        if (expense.amount > 100) {
          insight = 'Entertainment expenses are high this month. Look for free alternatives.';
        }
        break;
      case ExpenseCategory.shopping:
        if (expense.amount > 200) {
          insight = 'Shopping expenses are substantial. Consider if these purchases are necessary.';
        }
        break;
      default:
        break;
    }

    if (insight.isNotEmpty) {
      await _notificationService.showNotification(
        title: '💡 Spending Insight',
        body: insight,
      );
    }
  }

  // Weekly spending summary
  Future<void> showWeeklySummary({
    required double totalSpent,
    required double weeklyBudget,
    required List<ExpensesItem> topExpenses,
  }) async {
    await _notificationService.showWeeklySummary(
      totalSpent: totalSpent,
      weeklyBudget: weeklyBudget,
      topExpenses: topExpenses,
    );
  }

  // Monthly spending summary
  Future<void> showMonthlySummary({
    required double totalSpent,
    required double monthlyBudget,
    required Map<String, double> categoryBreakdown,
  }) async {
    final percentage = monthlyBudget > 0 ? (totalSpent / monthlyBudget) * 100 : 0;
    final remaining = monthlyBudget - totalSpent;
    
    String title, body;
    
    if (percentage >= 100) {
      title = '🚨 Monthly Budget Exceeded!';
      body = 'You\'ve spent ' + _fmt(totalSpent) + ' this month, exceeding your budget by ' + _fmt(remaining.abs()) + '.';
    } else if (percentage >= 80) {
      title = '⚠️ Monthly Budget Alert';
      body = 'You\'ve spent ' + _fmt(totalSpent) + ' this month (' + percentage.toStringAsFixed(1) + '% of budget). ' + _fmt(remaining) + ' remaining.';
    } else {
      title = '📊 Monthly Summary';
      body = 'You\'ve spent ' + _fmt(totalSpent) + ' this month (' + percentage.toStringAsFixed(1) + '% of budget). ' + _fmt(remaining) + ' remaining.';
    }

    // Add top spending category
    if (categoryBreakdown.isNotEmpty) {
      final topCategory = categoryBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b);
      body += '\n\nTop spending category: ${topCategory.key} (' + _fmt(topCategory.value) + ')';
    }

    await _notificationService.showNotification(title: title, body: body);
  }

  // Budget alerts
  Future<void> showBudgetAlert({
    required String budgetName,
    required double spent,
    required double limit,
    required double remaining,
  }) async {
    await _notificationService.showBudgetAlert(
      budgetName: budgetName,
      spent: spent,
      limit: limit,
      remaining: remaining,
    );
  }

  // Goal achievement
  Future<void> showGoalAchievement({
    required String goalName,
    required double targetAmount,
    required double currentAmount,
  }) async {
    await _notificationService.showGoalAchievement(
      goalName: goalName,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
    );
  }

  // Spending reminder
  Future<void> showSpendingReminder({
    required String message,
    DateTime? scheduledTime,
  }) async {
    await _notificationService.showSpendingReminder(
      message: message,
      scheduledTime: scheduledTime,
    );
  }

  // Schedule daily spending reminder
  Future<void> scheduleDailyReminder() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9, 0); // 9 AM tomorrow
    
    await _notificationService.scheduleNotification(
      title: '💡 Daily Reminder',
      body: 'Don\'t forget to record your expenses today!',
      scheduledDate: tomorrow,
      id: 999, // Special ID for daily reminder
    );
  }

  // Schedule weekly summary
  Future<void> scheduleWeeklySummary() async {
    final now = DateTime.now();
    final nextSunday = now.add(Duration(days: (7 - now.weekday) % 7));
    final summaryTime = DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 18, 0); // 6 PM on Sunday
    
    await _notificationService.scheduleNotification(
      title: '📊 Weekly Summary',
      body: 'Time to review your weekly spending!',
      scheduledDate: summaryTime,
      id: 998, // Special ID for weekly summary
    );
  }

  // Schedule monthly summary
  Future<void> scheduleMonthlySummary() async {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1, 18, 0); // 6 PM on 1st of next month
    
    await _notificationService.scheduleNotification(
      title: '📊 Monthly Summary',
      body: 'Time to review your monthly spending!',
      scheduledDate: nextMonth,
      id: 997, // Special ID for monthly summary
    );
  }

  // Cancel all scheduled notifications
  Future<void> cancelAllScheduledNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  // Get pending notifications
  Future<List<dynamic>> getPendingNotifications() async {
    return await _notificationService.getPendingNotifications();
  }

  // Direct notification method for testing and general use
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    await _notificationService.showNotification(
      title: title,
      body: body,
      payload: payload,
      id: id,
    );
  }
}
