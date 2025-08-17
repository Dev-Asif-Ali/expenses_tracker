import 'package:expenses_tracker/features/track_expenses/presentation/widgets/enhanced_expense_tile.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/widgets/enhanced_add_expense_dialog.dart';
import 'package:expenses_tracker/features/budget/presentation/widgets/budget_dashboard.dart';
import 'package:expenses_tracker/core/services/budget_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/bloc/expense_bloc.dart';
import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';
import 'package:expenses_tracker/core/notifications/notification_manager.dart';
import 'package:expenses_tracker/features/notifications/presentation/pages/notifications_page.dart';

import '../../../../core/services/user_profile_service.dart';

class HomePage extends StatefulWidget {
  final List<ExpensesItem> expenses;
  final Function(ExpensesItem) onAddExpense;
  final Function(ExpensesItem) onUpdateExpense;
  final Function(ExpensesItem) onDeleteExpense;

  const HomePage({
    super.key, 
    required this.expenses,
    required this.onAddExpense,
    required this.onUpdateExpense,
    required this.onDeleteExpense,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ExpenseBloc _expenseBloc;
  List<ExpensesItem> _currentExpenses = [];
  List<ExpensesItem> _filteredExpenses = [];
  final NotificationManager _notificationManager = NotificationManager();
  
  // Search and filter variables
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedTimeFilter = 'All Time';
  double? _minAmount;
  double? _maxAmount;
  
  // Available categories and time filters
  final List<String> _categories = [
    'All', 'Food', 'Transport', 'Entertainment', 'Shopping', 
    'Health', 'Education', 'Utilities', 'Housing', 'Other'
  ];
  
  final List<String> _timeFilters = [
    'All Time', 'Today', 'This Week', 'This Month', 'Last Month'
  ];

  @override
  void initState() {
    super.initState();
    _expenseBloc = BlocProvider.of<ExpenseBloc>(context);
    _currentExpenses = List.from(widget.expenses);
    _filteredExpenses = List.from(_currentExpenses);
    _applyFilters();
  }

  @override
  void dispose() {
    _expenseBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  void _addExpense(ExpensesItem expense) async {
    // Call the parent callback to update the shared list
    widget.onAddExpense(expense);
    
    // Update local state
    setState(() {
      _currentExpenses.add(expense);
    });
    
    _applyFilters(); // Apply filters to include new expense
    
    // Show notification
    await _notificationManager.onExpenseAdded(expense);
  }

  void _editExpense(ExpensesItem expense) {
    showDialog(
      context: context,
      builder: (context) => EnhancedAddExpenseDialog(
        expenseToEdit: expense,
                  onSave: (editedExpense) async {
            // Call the parent callback to update the shared list
            widget.onUpdateExpense(editedExpense);
            
            // Update local state
            setState(() {
              final index = _currentExpenses.indexWhere((e) => e.id == editedExpense.id);
              if (index != -1) {
                _currentExpenses[index] = editedExpense;
              }
            });
            
            _applyFilters(); // Apply filters after editing
            
            // Show notification
            await _notificationManager.onExpenseUpdated(editedExpense);
          },
      ),
    );
  }

  void _deleteExpense(ExpensesItem expense) async {
    // Call the parent callback to update the shared list
    widget.onDeleteExpense(expense);
    
    // Update local state
    setState(() {
      _currentExpenses.removeWhere((e) => e.id == expense.id);
    });
    
    _applyFilters(); // Apply filters after deletion
    
    // Show notification
    await _notificationManager.onExpenseDeleted(expense);
  }

  void _handleBudgetExceeded() {
    final budgetNotificationService = BudgetNotificationService();
    budgetNotificationService.showBudgetExceededNotification(context, _currentExpenses);
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsPage(expenses: _currentExpenses),
      ),
    );
  }

  // Apply search and filters
  void _applyFilters() {
    setState(() {
      _filteredExpenses = _currentExpenses.where((expense) {
                 // Search query filter
         if (_searchQuery.isNotEmpty) {
           final query = _searchQuery.toLowerCase();
           if (!expense.name.toLowerCase().contains(query) &&
               !expense.category.name.toLowerCase().contains(query) &&
               !(expense.note?.toLowerCase().contains(query) ?? false)) {
             return false;
           }
         }

        // Category filter
        if (_selectedCategory != 'All' && expense.category.name != _selectedCategory) {
          return false;
        }

        // Amount range filter
        if (_minAmount != null && expense.amount < _minAmount!) {
          return false;
        }
        if (_maxAmount != null && expense.amount > _maxAmount!) {
          return false;
        }

        // Time filter
        if (_selectedTimeFilter != 'All Time') {
          final now = DateTime.now();
          final expenseDate = expense.dateTime;
          
          switch (_selectedTimeFilter) {
            case 'Today':
              if (!_isSameDay(expenseDate, now)) return false;
              break;
            case 'This Week':
              if (!_isSameWeek(expenseDate, now)) return false;
              break;
            case 'This Month':
              if (!_isSameMonth(expenseDate, now)) return false;
              break;
            case 'Last Month':
              if (!_isLastMonth(expenseDate, now)) return false;
              break;
          }
        }

        return true;
      }).toList();
    });
  }

  // Helper methods for time filtering
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    final week1 = date1.difference(DateTime(date1.year, date1.month, 1)).inDays ~/ 7;
    final week2 = date2.difference(DateTime(date2.year, date2.month, 1)).inDays ~/ 7;
    return date1.year == date2.year && date1.month == date2.month && week1 == week2;
  }

  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  bool _isLastMonth(DateTime date1, DateTime date2) {
    final lastMonth = DateTime(date2.year, date2.month - 1, date2.day);
    return date1.year == lastMonth.year && date1.month == lastMonth.month;
  }

  // Show advanced filters dialog
  void _showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Advanced Filters'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category filter
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                ),
                const SizedBox(height: 16),
                
                // Time filter
                DropdownButtonFormField<String>(
                  value: _selectedTimeFilter,
                  decoration: const InputDecoration(
                    labelText: 'Time Period',
                    border: OutlineInputBorder(),
                  ),
                  items: _timeFilters.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedTimeFilter = value!);
                  },
                ),
                const SizedBox(height: 16),
                
                // Amount range
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Min Amount',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _minAmount = double.tryParse(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Max Amount',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _maxAmount = double.tryParse(value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Reset filters
                _selectedCategory = 'All';
                _selectedTimeFilter = 'All Time';
                _minAmount = null;
                _maxAmount = null;
                Navigator.of(context).pop();
                _applyFilters();
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applyFilters();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search expenses...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _searchQuery = '';
                                _applyFilters();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showAdvancedFilters,
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                IconButton(
                  onPressed: _navigateToNotifications,
                  icon: const Icon(Icons.notifications),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Budget Dashboard
                  BudgetDashboard(
                    expenses: _currentExpenses,
                    onBudgetExceeded: () => _handleBudgetExceeded(),
                  ),
                  
                  // Filter Summary
                  if (_searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedTimeFilter != 'All Time')
                    _buildFilterSummary(),
                  
                  // Summary Section
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .35,
                    child: _buildSummarySection(),
                  ),
                  
                  // Expenses List
                  _buildExpensesList(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          final width = MediaQuery.of(context).size.width;
          final isCompact = width < 380;
          if (isCompact) {
            return FloatingActionButton(
              onPressed: _showAddExpenseDialog,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add, size: 22),
            );
          }
          return FloatingActionButton.extended(
            onPressed: _showAddExpenseDialog,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add, size: 22),
            label: const Text('Add Expense'),
          );
        },
      ),
    );
  }



  Widget _buildSummarySection() {
    final totalSpent = _filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final categoryBreakdown = _getCategoryBreakdown();
    final userProfileService = UserProfileService();
    final profile = userProfileService.currentProfile;
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Spent Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Spent This Month',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                                     Text(
                     profile?.formatAmount(totalSpent) ?? '\$${totalSpent.toStringAsFixed(2)}',
                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: Theme.of(context).colorScheme.primary,
                     ),
                   ),
                  const SizedBox(height: 16),
                                     Text(
                     '${_filteredExpenses.length} expenses',
                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                       color: Colors.grey.shade600,
                     ),
                   ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Category Overview
          if (categoryBreakdown.isNotEmpty) ...[
            Text(
              'Top Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryBreakdown.entries.take(5).length,
                itemBuilder: (context, index) {
                  final entry = categoryBreakdown.entries.elementAt(index);
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(entry.key),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _getCategoryIcon(entry.key),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                                                 Text(
                           profile?.formatAmount(entry.value) ?? '\$${entry.value.toStringAsFixed(0)}',
                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing ${_filteredExpenses.length} of ${_currentExpenses.length} expenses',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              _searchQuery = '';
              _selectedCategory = 'All';
              _selectedTimeFilter = 'All Time';
              _minAmount = null;
              _maxAmount = null;
              _applyFilters();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    if (_currentExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first expense to get started!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredExpenses.length,
      itemBuilder: (context, index) {
        final expense = _filteredExpenses[index];
        return EnhancedExpenseTile(
          expense: expense,
          onDelete: () => _deleteExpense(expense),
          onEdit: () => _editExpense(expense),
          onTap: () => _editExpense(expense),
        );
      },
    );
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => EnhancedAddExpenseDialog(
        onSave: _addExpense,
      ),
    );
  }

  Map<String, double> _getCategoryBreakdown() {
    final breakdown = <String, double>{};
    for (final expense in _filteredExpenses) {
      final category = expense.category.name;
      breakdown[category] = (breakdown[category] ?? 0) + expense.amount;
    }
    
    // Sort by amount descending
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'food':
        return const Color(0xFFFF6B6B);
      case 'transport':
        return const Color(0xFF4ECDC4);
      case 'entertainment':
        return const Color(0xFF45B7D1);
      case 'shopping':
        return const Color(0xFF96CEB4);
      case 'health':
        return const Color(0xFFFFEAA7);
      case 'education':
        return const Color(0xFFDDA0DD);
      case 'utilities':
        return const Color(0xFF98D8C8);
      case 'housing':
        return const Color(0xFFF7DC6F);
      default:
        return const Color(0xFFBDC3C7);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'health':
        return Icons.health_and_safety;
      case 'education':
        return Icons.school;
      case 'utilities':
        return Icons.electric_bolt;
      case 'housing':
        return Icons.home;
      default:
        return Icons.more_horiz;
    }
  }
}
