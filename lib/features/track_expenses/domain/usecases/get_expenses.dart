import 'package:expenses_tracker/features/track_expenses/domain/repositories/expense_repo.dart';

import '../entities/expenses_item.dart';

class GetExpenses {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  Future<List<ExpensesItem>> call() async {
    return await repository.getExpenses();
  }
}
