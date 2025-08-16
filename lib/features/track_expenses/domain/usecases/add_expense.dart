
import '../../data/repositories/expenses_repo_impl.dart';
import '../entities/expenses_item.dart';
import '../repositories/expense_repo.dart';

class AddExpense {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  Future<List<ExpensesItem>> call(ExpensesItem newExpense) async {
    return await repository.addExpense(newExpense);
  }
}
