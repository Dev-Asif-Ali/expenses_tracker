import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';

abstract class ExpenseRepository {
  Future<List<ExpensesItem>> getExpenses();
  Future<List<ExpensesItem>> addExpense(ExpensesItem expense);
    Future<void> deleteExpense(ExpensesItem expense);
}