import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/services/user_profile_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/expenses_item.dart';


class AnalyticsDashboard extends StatefulWidget {
  final List<ExpensesItem> expenses;
  final DateTime startDate;
  final DateTime endDate;

  const AnalyticsDashboard({
    super.key,
    required this.expenses,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Start auto-scrolling animation
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
        _nextPage();
      }
    });
    
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    
    if (mounted) {
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _animationController.forward();
    }
  }

  // Helper method to format amounts with user's currency
  String _formatAmount(double amount) {
    try {
      final userProfileService = UserProfileService();
      if (userProfileService.hasProfile) {
        final profile = userProfileService.userProfile;
        return profile?.formatAmount(amount) ?? '\$${amount.toStringAsFixed(2)}';
      }
    } catch (e) {
      // Fallback to default format if there's an error
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = widget.expenses.where((expense) =>
        expense.dateTime.isAfter(widget.startDate) && expense.dateTime.isBefore(widget.endDate)).toList();
    
    final totalSpent = filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final categoryBreakdown = _getCategoryBreakdown(filteredExpenses);
    final topExpenses = _getTopExpenses(filteredExpenses);
    final spendingTrend = _getSpendingTrend(filteredExpenses);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards with Slidable Animation
          _buildSlidableSummaryCards(context, totalSpent, filteredExpenses.length, filteredExpenses),
          const SizedBox(height: 24),
          
          // Category Breakdown
          _buildCategoryBreakdown(context, categoryBreakdown, totalSpent),
          const SizedBox(height: 24),
          
          // Spending Trend
          _buildSpendingTrend(context, spendingTrend),
          const SizedBox(height: 24),
          
          // Top Expenses
          _buildTopExpenses(context, topExpenses),
        ],
      ),
    );
  }

  Widget _buildSlidableSummaryCards(BuildContext context, double totalSpent, int expenseCount, List<ExpensesItem> filteredExpenses) {
    final daysBetween = _getDaysBetween(widget.startDate, widget.endDate);
    final dailyAverage = daysBetween > 0 ? totalSpent / daysBetween : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: 3,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _SlidableSummaryCard(
                    title: 'Total Spent',
                    value: _formatAmount(totalSpent),
                    subtitle: '${filteredExpenses.length} expenses',
                    icon: Icons.account_balance_wallet,
                    color: Theme.of(context).colorScheme.primary,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                  );
                case 1:
                  return _SlidableSummaryCard(
                    title: 'Total Expenses',
                    value: expenseCount.toString(),
                    subtitle: 'transactions',
                    icon: Icons.receipt_long,
                    color: Theme.of(context).colorScheme.secondary,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
                      ],
                    ),
                  );
                case 2:
                  return _SlidableSummaryCard(
                    title: 'Daily Average',
                    value: _formatAmount(dailyAverage),
                    subtitle: 'per day',
                    icon: Icons.trending_up,
                    color: Theme.of(context).colorScheme.tertiary,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.tertiary,
                        Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.7),
                      ],
                    ),
                  );
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        // Page Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, Map<String, double> breakdown, double total) {
    final sortedCategories = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Pie Chart
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: sortedCategories.map((entry) {
                          final percentage = (entry.value / total * 100);
                          return PieChartSectionData(
                            color: AppTheme.getCategoryColor(entry.key),
                            value: entry.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Legend
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: sortedCategories.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppTheme.getCategoryColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key.toUpperCase(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                                                                                              Text(
                                   _formatAmount(entry.value),
                                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingTrend(BuildContext context, List<MapEntry<DateTime, double>> trend) {
    if (trend.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                                                                                                   getTitlesWidget: (value, meta) {
                            return Text(
                              _formatAmount(value),
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < trend.length) {
                            final date = trend[value.toInt()].key;
                            return Text(
                              '${date.month}/${date.day}',
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: trend.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopExpenses(BuildContext context, List<ExpensesItem> topExpenses) {
    if (topExpenses.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Expenses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...topExpenses.map((expense) {
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.getCategoryColor(expense.category.name),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(expense.name),
                subtitle: Text(expense.category.name),
                                                                   trailing: Text(
                    _formatAmount(expense.amount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Map<String, double> _getCategoryBreakdown(List<ExpensesItem> expenses) {
    final breakdown = <String, double>{};
    for (final expense in expenses) {
      final category = expense.category.name;
      breakdown[category] = (breakdown[category] ?? 0) + expense.amount;
    }
    return breakdown;
  }

  List<ExpensesItem> _getTopExpenses(List<ExpensesItem> expenses) {
    final sorted = List<ExpensesItem>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.take(5).toList();
  }

  List<MapEntry<DateTime, double>> _getSpendingTrend(List<ExpensesItem> expenses) {
    final dailySpending = <DateTime, double>{};
    for (final expense in expenses) {
      final date = DateTime(expense.dateTime.year, expense.dateTime.month, expense.dateTime.day);
      dailySpending[date] = (dailySpending[date] ?? 0) + expense.amount;
    }
    
    final sorted = dailySpending.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted;
  }

  int _getDaysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.health:
        return Icons.health_and_safety;
      case ExpenseCategory.education:
        return Icons.school;
      case ExpenseCategory.utilities:
        return Icons.electric_bolt;
      case ExpenseCategory.housing:
        return Icons.home;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }
}

class _SlidableSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Gradient gradient;

  const _SlidableSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 8,
        shadowColor: color.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: gradient,
          ),
                     child: Padding(
             padding: const EdgeInsets.all(20),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(
                   icon,
                   color: Colors.white,
                   size: 36,
                 ),
                 const SizedBox(height: 12),
                 Flexible(
                   child: Text(
                     value,
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                     ),
                     textAlign: TextAlign.center,
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 const SizedBox(height: 6),
                 Flexible(
                   child: Text(
                     title,
                     style: Theme.of(context).textTheme.titleSmall?.copyWith(
                       color: Colors.white,
                       fontWeight: FontWeight.w600,
                     ),
                     textAlign: TextAlign.center,
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 const SizedBox(height: 2),
                 Flexible(
                   child: Text(
                     subtitle,
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                       color: Colors.white.withValues(alpha: 0.8),
                     ),
                     textAlign: TextAlign.center,
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
               ],
             ),
           ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
