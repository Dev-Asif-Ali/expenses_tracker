import 'dart:developer';
import 'package:expenses_tracker/features/track_expenses/data/datasources/hive_database.dart';
import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';
import 'package:expenses_tracker/features/track_expenses/domain/repositories/expense_repo.dart';
import 'package:expenses_tracker/core/datetime/date_time.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  List<ExpensesItem> overallExpensesList = [];

  final HiveDataBase db = HiveDataBase();

  ExpenseRepositoryImpl() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    final data = db.readData();
    if (data.isNotEmpty) {
      overallExpensesList = data;
    }
  }

  @override
  Future<List<ExpensesItem>> getExpenses() async {
    return overallExpensesList;
  }

  @override
  Future<List<ExpensesItem>> addExpense(ExpensesItem newExpense) async {
    db.saveData(overallExpensesList);
    overallExpensesList.add(newExpense);
    return overallExpensesList;
  }

  @override
  Future<void> deleteExpense(ExpensesItem expense) async {
    db.saveData(overallExpensesList);
    overallExpensesList.remove(expense);
    
  }

  String getDayName(DateTime dateTime) {
    switch (dateTime.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  DateTime startOfWeek() {
    DateTime today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday));
    log(startOfWeek.toString());
    return startOfWeek;
  }

  Map<String, double> calculateDailyExpenses() {
    Map<String, double> dailyExpensesSummary = {};
    for (var expense in overallExpensesList) {
      String date = convertDateTimeToString(expense.dateTime);
      double amount = double.parse(expense.amount);

      if (dailyExpensesSummary.containsKey(date)) {
        dailyExpensesSummary[date] = dailyExpensesSummary[date]! + amount;
      } else {
        dailyExpensesSummary[date] = amount;
      }
    }
    log(dailyExpensesSummary.toString());
    return dailyExpensesSummary;
  }
}
