import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/services/user_profile_service.dart';
import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';

class NotificationsPage extends StatefulWidget {
  final List<ExpensesItem> expenses;

  const NotificationsPage({
    super.key,
    required this.expenses,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _dailyReminders = true;
  bool _weeklySummaries = true;
  bool _monthlySummaries = true;
  bool _budgetAlerts = true;
  bool _spendingTrends = true;
  bool _lowBudgetWarnings = true;
  bool _categoryAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Notification Preferences',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                                         Text(
                       'Customize how and when you receive notifications',
                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                         color: Theme.of(context).colorScheme.onBackground.withValues(alpha: 0.7),
                       ),
                     ),
                     
                     // Save Button
                     Container(
                       margin: const EdgeInsets.only(top: 16),
                       child: ElevatedButton(
                         onPressed: _saveSettings,
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Theme.of(context).colorScheme.primary,
                           foregroundColor: Colors.white,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(8),
                           ),
                         ),
                         child: const Text('Save Settings'),
                       ),
                     ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Reminder Notifications
            _buildSectionHeader('Reminder Notifications', Icons.alarm),
            _buildNotificationTile(
              title: 'Daily Reminders',
              subtitle: 'Get reminded to record your daily expenses',
              icon: Icons.today,
              value: _dailyReminders,
              onChanged: (value) => setState(() => _dailyReminders = value),
            ),
            _buildNotificationTile(
              title: 'Weekly Summaries',
              subtitle: 'Receive weekly spending summaries every Sunday',
              icon: Icons.calendar_view_week,
              value: _weeklySummaries,
              onChanged: (value) => setState(() => _weeklySummaries = value),
            ),
            _buildNotificationTile(
              title: 'Monthly Summaries',
              subtitle: 'Get detailed monthly spending reports',
              icon: Icons.calendar_month,
              value: _monthlySummaries,
              onChanged: (value) => setState(() => _monthlySummaries = value),
            ),
            
            const SizedBox(height: 24),
            
            // Budget Notifications
            _buildSectionHeader('Budget Notifications', Icons.account_balance_wallet),
            _buildNotificationTile(
              title: 'Budget Alerts',
              subtitle: 'Get notified when you exceed your daily budget',
              icon: Icons.warning,
              value: _budgetAlerts,
              onChanged: (value) => setState(() => _budgetAlerts = value),
            ),
            _buildNotificationTile(
              title: 'Low Budget Warnings',
              subtitle: 'Alert when remaining budget is below 20%',
              icon: Icons.info,
              value: _lowBudgetWarnings,
              onChanged: (value) => setState(() => _lowBudgetWarnings = value),
            ),
            
            const SizedBox(height: 24),
            
            // Smart Notifications
            _buildSectionHeader('Smart Notifications', Icons.psychology),
            _buildNotificationTile(
              title: 'Spending Trends',
              subtitle: 'Get insights about your spending patterns',
              icon: Icons.trending_up,
              value: _spendingTrends,
              onChanged: (value) => setState(() => _spendingTrends = value),
            ),
            _buildNotificationTile(
              title: 'Category Alerts',
              subtitle: 'Notify when spending heavily in one category',
              icon: Icons.category,
              value: _categoryAlerts,
              onChanged: (value) => setState(() => _categoryAlerts = value),
            ),
            
            const SizedBox(height: 24),
            
            // Notification Preview
            if (_budgetAlerts) _buildBudgetPreview(),
            
            const SizedBox(height: 32),
            
            // Test Notifications Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _testNotifications,
                icon: const Icon(Icons.notifications),
                label: const Text('Test Notifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildBudgetPreview() {
    final userProfileService = UserProfileService();
    final profile = userProfileService.currentProfile;
    
    if (profile == null) return const SizedBox.shrink();
    
    final dailySpending = userProfileService.getDailySpending(widget.expenses);
    final isExceeded = userProfileService.isDailyBudgetExceeded(widget.expenses);
    
    if (!isExceeded) return const SizedBox.shrink();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Budget Alert Preview',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Daily Budget Exceeded!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You\'ve spent ${profile.formatAmount(dailySpending - profile.dailyBudget)} more than your daily budget of ${profile.formatAmount(profile.dailyBudget)}',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implement saving notification preferences
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification preferences saved!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _testNotifications() {
    // TODO: Implement test notifications
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
