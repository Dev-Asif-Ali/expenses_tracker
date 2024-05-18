import 'package:expenses_tracker/features/track_expenses/domain/repositories/expense_repo.dart';

import '../entities/expenses_item.dart';

class DeleteExpense {
  final ExpenseRepository repository;

  DeleteExpense(this.repository);

  Future<void> call(ExpensesItem expense) async {
    return await repository.deleteExpense(expense);
  }
}
