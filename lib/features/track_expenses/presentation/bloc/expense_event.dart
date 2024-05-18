// lib/presentation/blocs/expense_event.dart
import 'package:equatable/equatable.dart';
import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';


abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object> get props => [];
}

class FetchExpenses extends ExpenseEvent {
  // final ExpensesItem newExpense;

  // const FetchExpenses(this.newExpense);

  // @override
  // List<Object> get props => [newExpense];
}

class AddExpenseEvent extends ExpenseEvent {
  final ExpensesItem newExpense;

  const AddExpenseEvent(this.newExpense);

  @override
  List<Object> get props => [newExpense];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final ExpensesItem expense;

  const DeleteExpenseEvent(this.expense);

  @override
  List<Object> get props => [expense];
}
