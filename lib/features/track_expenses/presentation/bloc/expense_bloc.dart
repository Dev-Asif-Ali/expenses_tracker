// lib/presentation/blocs/expense_bloc.dart
import 'dart:async';
import 'dart:math';

import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';
import 'package:expenses_tracker/features/track_expenses/domain/usecases/get_expenses.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpenses getExpenses;
  final AddExpense addExpense;
  final DeleteExpense deleteExpense;

  ExpenseBloc(
      {required this.getExpenses,
      required this.addExpense,
      required this.deleteExpense})
      : super(ExpenseInitial()) {
    on<FetchExpenses>(fetchExpenses);
    on<AddExpenseEvent>(_addExpense);
    on<DeleteExpenseEvent>(_deleteExpense);
  }

  FutureOr<void> fetchExpenses(
      FetchExpenses event, Emitter<ExpenseState> emit) async {
    // emit(ExpensesLoading());
    var res = await getExpenses();
    if (res.isNotEmpty) {
      emit(ExpensesLoaded(res));
    } else {
      emit(const ExpenseError('No Expneses Added..'));
    }
  }

  FutureOr<void> _addExpense(
      AddExpenseEvent event, Emitter<ExpenseState> emit) async {
    try {
      // emit(ExpensesLoading());
      var newExpense = event.newExpense;
      var updatedExpensesList = await addExpense(newExpense);
      print('Expense added successfully, updated list: $updatedExpensesList');
      emit(ExpensesAdded(updatedExpensesList));
    } catch (e) {
      emit(const ExpenseError('Failed to add the expense'));
    }
  }

  FutureOr<void> _deleteExpense(
      DeleteExpenseEvent event, Emitter<ExpenseState> emit) async {
    try {
      // emit(ExpensesLoading());
      var expenseToDelete = event.expense;
      deleteExpense(expenseToDelete);
      emit(ExpensesDeleted());
    } catch (e) {
      emit(const ExpenseError('Failed to delete the expense'));
    }
  }
}
