import 'package:flutter/material.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/pages/home_page.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/widgets/analytics_dashboard.dart';
import 'package:expenses_tracker/features/profile/presentation/pages/profile_page.dart';
import 'package:expenses_tracker/features/budget/presentation/pages/budgets_page.dart';
import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';
import 'package:expenses_tracker/core/services/user_profile_service.dart';

class MainNavigation extends StatefulWidget {
  final List<ExpensesItem>? expenses;

  const MainNavigation({
    super.key,
    this.expenses,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;
  late List<ExpensesItem> _allExpenses;
  late ValueNotifier<List<ExpensesItem>> _expensesNotifier;
  int _expensesVersion = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    // Use passed expenses if available, otherwise start with empty list
    _allExpenses = widget.expenses ?? [];
    _expensesNotifier = ValueNotifier<List<ExpensesItem>>(List.from(_allExpenses));
  }

  // Method to add expense from any tab
  void _addExpense(ExpensesItem expense) {
    setState(() {
      _allExpenses.add(expense);
    });
    _expensesNotifier.value = List.from(_allExpenses);
    _expensesVersion++;
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${expense.name} - ${_formatAmount(expense.amount)}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Method to update expense from any tab
  void _updateExpense(ExpensesItem expense) {
    setState(() {
      final index = _allExpenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _allExpenses[index] = expense;
      }
    });
    _expensesNotifier.value = List.from(_allExpenses);
    _expensesVersion++;
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated ${expense.name}'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Method to delete expense from any tab
  void _deleteExpense(ExpensesItem expense) {
    setState(() {
      _allExpenses.removeWhere((e) => e.id == expense.id);
    });
    _expensesNotifier.value = List.from(_allExpenses);
    _expensesVersion++;
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted ${expense.name}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Expenses';
      case 1:
        return 'Analytics';
      case 2:
        return 'Budgets';
      case 3:
        return 'Profile';
      default:
        return 'Expenses Tracker Pro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(25),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
        actions: [
          if (_allExpenses.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showExpenseSummary,
              tooltip: 'Expense Summary',
            ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Expenses Page
          HomePage(
            expenses: _allExpenses,
            onAddExpense: _addExpense,
            onUpdateExpense: _updateExpense,
            onDeleteExpense: _deleteExpense,
          ),
          
          // Analytics Page
          _buildAnalyticsPage(),
          
          // Budgets Page
          _buildBudgetsPage(),
          
          // Profile Page
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(25),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabTapped,
            backgroundColor: Theme.of(context).colorScheme.surface,
            indicatorColor: Theme.of(context).colorScheme.primaryContainer,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.receipt_long),
                label: 'Expenses',
              ),
              NavigationDestination(
                icon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet),
                label: 'Budgets',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsPage() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return AnalyticsDashboard(
      expenses: _allExpenses,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  Widget _buildBudgetsPage() {
    return ValueListenableBuilder<List<ExpensesItem>>(
      valueListenable: _expensesNotifier,
      builder: (context, expenses, _) {
        return BudgetsPage(key: ValueKey(_expensesVersion), expenses: expenses);
      },
    );
  }

  void _showBudgetComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Budget management will be available in the next update!'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showExpenseSummary() {
    if (_allExpenses.isEmpty) return;
    
    final totalSpent = _allExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final totalExpenses = _allExpenses.length;
    final averageExpense = totalSpent / totalExpenses;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expense Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Expenses: $totalExpenses'),
            Text('Total Spent: ${_formatAmount(totalSpent)}'),
            Text('Average per Expense: ${_formatAmount(averageExpense)}'),
        ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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


}
