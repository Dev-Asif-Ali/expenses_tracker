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
    overallExpensesList.add(newExpense);
    db.saveData(overallExpensesList);
    return overallExpensesList;
  }

  @override
  Future<void> deleteExpense(ExpensesItem expense) async {
    overallExpensesList.removeWhere((e) => e.id == expense.id);
    db.saveData(overallExpensesList);
  }

  @override
  Future<void> updateExpense(ExpensesItem expense) async {
    final index = overallExpensesList.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      overallExpensesList[index] = expense;
      db.saveData(overallExpensesList);
    }
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
      double amount = expense.amount; // Now amount is already a double

      if (dailyExpensesSummary.containsKey(date)) {
        dailyExpensesSummary[date] = dailyExpensesSummary[date]! + amount;
      } else {
        dailyExpensesSummary[date] = amount;
      }
    }
    log(dailyExpensesSummary.toString());
    return dailyExpensesSummary;
  }

  // New methods for enhanced functionality
  List<ExpensesItem> getExpensesByCategory(ExpenseCategory category) {
    return overallExpensesList.where((expense) => expense.category == category).toList();
  }

  // Helper method to convert DateTime to string
  String convertDateTimeToString(DateTime dateTime) {
    String year = dateTime.year.toString();
    String month = dateTime.month.toString();
    if (month.length == 1) {
      month = '0' + month;
    }
    String day = dateTime.day.toString();
    if (day.length == 1) {
      day = '0' + day;
    }
    String yyyymmdd = year + month + day;
    return yyyymmdd;
  }

  List<ExpensesItem> getExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return overallExpensesList.where((expense) => 
      expense.dateTime.isAfter(startDate) && expense.dateTime.isBefore(endDate)
    ).toList();
  }

  List<ExpensesItem> getRecurringExpenses() {
    return overallExpensesList.where((expense) => expense.isRecurring).toList();
  }

  double getTotalExpenses() {
    return overallExpensesList.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double getTotalExpensesByCategory(ExpenseCategory category) {
    return overallExpensesList
        .where((expense) => expense.category == category)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }
}
