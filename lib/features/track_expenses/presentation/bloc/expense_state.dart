
import 'package:equatable/equatable.dart';
import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpensesLoaded extends ExpenseState {
  final List<ExpensesItem> expenses;

  const ExpensesLoaded(this.expenses);

  @override
  List<Object> get props => [expenses];
}

class ExpensesAdded extends ExpenseState {
  final List<ExpensesItem> expenses;

  const ExpensesAdded(this.expenses);
  @override
  List<Object> get props => [expenses];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object> get props => [message];
}

class ExpensesDeleted extends ExpenseState{

}

class ExpensesLoading extends ExpenseState{

}