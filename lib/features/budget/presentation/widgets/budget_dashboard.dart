import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/models/user_profile.dart';
import 'package:expenses_tracker/core/services/user_profile_service.dart';
import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';

class BudgetDashboard extends StatelessWidget {
  final List<ExpensesItem> expenses;
  final VoidCallback? onBudgetExceeded;

  const BudgetDashboard({
    super.key,
    required this.expenses,
    this.onBudgetExceeded,
  });

  // Static flag to prevent multiple notifications
  static bool _hasShownBudgetExceeded = false;

  @override
  Widget build(BuildContext context) {
    final profileService = UserProfileService();
    final profile = profileService.currentProfile;
    
    if (profile == null) {
      return _buildNoProfileCard(context);
    }

    final dailySpending = profileService.getDailySpending(expenses);
    final remainingBudget = profileService.getRemainingDailyBudget(expenses);
    final budgetPercentage = profileService.getDailyBudgetPercentage(expenses);
    final isExceeded = profileService.isDailyBudgetExceeded(expenses);

    // Show notification if budget is exceeded (only once per build)
    if (isExceeded && onBudgetExceeded != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Use a flag to prevent multiple notifications
        if (!_hasShownBudgetExceeded) {
          _hasShownBudgetExceeded = true;
          onBudgetExceeded!();
        }
      });
    } else if (!isExceeded) {
      // Reset flag when budget is no longer exceeded
      _hasShownBudgetExceeded = false;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Budget',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hello, ${profile.name}!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isExceeded ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isExceeded ? 'Exceeded' : 'On Track',
                    style: TextStyle(
                      color: isExceeded ? Colors.red.shade700 : Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Budget Progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spent Today',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.formatAmount(dailySpending),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isExceeded ? Colors.red : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Daily Limit',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.formatAmount(profile.dailyBudget),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '${budgetPercentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isExceeded ? Colors.red : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (budgetPercentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isExceeded ? Colors.red : Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Remaining Budget
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isExceeded 
                    ? Colors.red.shade50 
                    : remainingBudget < profile.dailyBudget * 0.2 
                        ? Colors.orange.shade50 
                        : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isExceeded 
                      ? Colors.red.shade200 
                      : remainingBudget < profile.dailyBudget * 0.2 
                          ? Colors.orange.shade200 
                          : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isExceeded 
                        ? Icons.warning 
                        : remainingBudget < profile.dailyBudget * 0.2 
                            ? Icons.info 
                            : Icons.check_circle,
                    color: isExceeded 
                        ? Colors.red 
                        : remainingBudget < profile.dailyBudget * 0.2 
                            ? Colors.orange 
                            : Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isExceeded 
                              ? 'Budget Exceeded!'
                              : remainingBudget < profile.dailyBudget * 0.2 
                                  ? 'Budget Alert'
                                  : 'Great Job!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isExceeded 
                                ? Colors.red 
                                : remainingBudget < profile.dailyBudget * 0.2 
                                    ? Colors.orange 
                                    : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isExceeded 
                              ? 'You\'ve spent ${profile.formatAmount(dailySpending - profile.dailyBudget)} more than your daily budget'
                              : remainingBudget < profile.dailyBudget * 0.2 
                                  ? 'Only ${profile.formatAmount(remainingBudget)} remaining today'
                                  : 'You have ${profile.formatAmount(remainingBudget)} remaining today',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Additional Insights
            if (expenses.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Insights',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInsightItem(
                            context,
                            icon: Icons.receipt_long,
                            label: 'Expenses',
                            value: expenses.where((e) => _isSameDay(e.dateTime, DateTime.now())).length.toString(),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Expanded(
                          child: _buildInsightItem(
                            context,
                            icon: Icons.category,
                            label: 'Categories',
                            value: expenses
                                .where((e) => _isSameDay(e.dateTime, DateTime.now()))
                                .map((e) => e.category.name)
                                .toSet()
                                .length
                                .toString(),
                            color: Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _buildInsightItem(
                            context,
                            icon: Icons.analytics,
                            label: 'Avg/Expense',
                            value: profile.formatAmount(
                              dailySpending / expenses.where((e) => _isSameDay(e.dateTime, DateTime.now())).length
                            ),
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoProfileCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.account_circle,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Profile Set',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set up your profile to track daily budget',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to profile setup
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Set Up Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onBackground.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
}
