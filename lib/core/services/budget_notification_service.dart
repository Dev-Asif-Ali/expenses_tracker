import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/services/user_profile_service.dart';
import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';

class BudgetNotificationService {
  static final BudgetNotificationService _instance = BudgetNotificationService._internal();
  factory BudgetNotificationService() => _instance;
  BudgetNotificationService._internal();

  final UserProfileService _userProfileService = UserProfileService();
  bool _hasShownBudgetExceededNotification = false;
  DateTime? _lastNotificationDate;

  // Check if we should show budget notification
  bool shouldShowBudgetNotification(List<ExpensesItem> expenses) {
    final profile = _userProfileService.currentProfile;
    if (profile == null) return false;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    // Reset notification flag for new day
    if (_lastNotificationDate == null || _lastNotificationDate!.isBefore(todayDate)) {
      _hasShownBudgetExceededNotification = false;
      _lastNotificationDate = todayDate;
    }

    // Check if budget is exceeded and we haven't shown notification today
    if (!_hasShownBudgetExceededNotification && 
        _userProfileService.isDailyBudgetExceeded(expenses)) {
      _hasShownBudgetExceededNotification = true;
      return true;
    }

    return false;
  }

  // Show budget exceeded notification
  void showBudgetExceededNotification(BuildContext context, List<ExpensesItem> expenses) {
    final profile = _userProfileService.currentProfile;
    if (profile == null) return;

    final dailySpending = _userProfileService.getDailySpending(expenses);
    final exceededAmount = dailySpending - profile.dailyBudget;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Daily Budget Exceeded!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'You\'ve spent ${profile.formatAmount(exceededAmount)} more than your limit',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View Details',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to budget details or analytics
            _showBudgetDetailsDialog(context, profile, expenses);
          },
        ),
      ),
    );
  }

  // Show budget details dialog
  void _showBudgetDetailsDialog(BuildContext context, dynamic profile, List<ExpensesItem> expenses) {
    final dailySpending = _userProfileService.getDailySpending(expenses);
    final remainingBudget = _userProfileService.getRemainingDailyBudget(expenses);
    final budgetPercentage = _userProfileService.getDailyBudgetPercentage(expenses);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.red.shade600),
              const SizedBox(width: 8),
              const Text('Budget Alert'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello ${profile.name},'),
              const SizedBox(height: 16),
              _buildBudgetRow('Daily Budget:', profile.formatAmount(profile.dailyBudget)),
              _buildBudgetRow('Spent Today:', profile.formatAmount(dailySpending), isExceeded: true),
              _buildBudgetRow('Remaining:', profile.formatAmount(remainingBudget), isExceeded: remainingBudget < 0),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (budgetPercentage / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${budgetPercentage.toStringAsFixed(1)}% of budget used',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to budget management
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Manage Budget'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetRow(String label, String amount, {bool isExceeded = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isExceeded ? Colors.red.shade600 : null,
            ),
          ),
        ],
      ),
    );
  }

  // Show budget warning notification (when approaching limit)
  void showBudgetWarningNotification(BuildContext context, List<ExpensesItem> expenses) {
    final profile = _userProfileService.currentProfile;
    if (profile == null) return;

    final remainingBudget = _userProfileService.getRemainingDailyBudget(expenses);
    final budgetPercentage = _userProfileService.getDailyBudgetPercentage(expenses);

    // Show warning when 80% of budget is used
    if (budgetPercentage >= 80 && budgetPercentage < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Budget Warning',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Only ${profile.formatAmount(remainingBudget)} remaining today',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Show spending trend notification
  void showSpendingTrendNotification(BuildContext context, List<ExpensesItem> expenses) {
    final profile = _userProfileService.currentProfile;
    if (profile == null) return;

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    final todaySpending = _userProfileService.getDailySpending(expenses);
    final yesterdaySpending = _getSpendingForDate(expenses, yesterday);
    
    if (yesterdaySpending > 0) {
      final change = todaySpending - yesterdaySpending;
      final changePercentage = (change / yesterdaySpending * 100);
      
      if (changePercentage > 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Spending Trend Alert',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Your spending is ${changePercentage.toStringAsFixed(1)}% higher than yesterday',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade600,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'View Details',
              textColor: Colors.white,
              onPressed: () {
                _showSpendingTrendDialog(context, profile, todaySpending, yesterdaySpending, changePercentage);
              },
            ),
          ),
        );
      }
    }
  }

  // Get spending for a specific date
  double _getSpendingForDate(List<ExpensesItem> expenses, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return expenses
        .where((expense) => 
            expense.dateTime.isAfter(startOfDay) && 
            expense.dateTime.isBefore(endOfDay))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Show spending trend details dialog
  void _showSpendingTrendDialog(BuildContext context, dynamic profile, double todaySpending, double yesterdaySpending, double changePercentage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.trending_up, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text('Spending Trend'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello ${profile.name},'),
              const SizedBox(height: 16),
              _buildTrendRow('Yesterday:', profile.formatAmount(yesterdaySpending)),
              _buildTrendRow('Today:', profile.formatAmount(todaySpending)),
              _buildTrendRow('Change:', '${changePercentage > 0 ? '+' : ''}${changePercentage.toStringAsFixed(1)}%', 
                           isIncrease: changePercentage > 0),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: changePercentage > 0 ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: changePercentage > 0 ? Colors.red.shade200 : Colors.green.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      changePercentage > 0 ? Icons.trending_up : Icons.trending_down,
                      color: changePercentage > 0 ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        changePercentage > 0 
                            ? 'Your spending is increasing. Consider reviewing your expenses.'
                            : 'Great job! Your spending is decreasing.',
                        style: TextStyle(
                          color: changePercentage > 0 ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to analytics or detailed view
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('View Analytics'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendRow(String label, String value, {bool isIncrease = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncrease ? Colors.red.shade600 : null,
            ),
          ),
        ],
      ),
    );
  }

  // Reset notification flags (useful for testing)
  void resetNotificationFlags() {
    _hasShownBudgetExceededNotification = false;
    _lastNotificationDate = null;
  }
}
