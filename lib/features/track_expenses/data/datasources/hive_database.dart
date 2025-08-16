import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';
import 'package:hive/hive.dart';

class HiveDataBase {
  final _myBox = Hive.box("expenses_database");

  void saveData(List<ExpensesItem> allExpense) {
    List<Map<String, dynamic>> allExpenseFormatted = [];
    for (var expense in allExpense) {
      allExpenseFormatted.add(expense.toMap());
    }
    _myBox.put("All_Expenses", allExpenseFormatted);
  }

  List<ExpensesItem> readData() {
    List savedExpense = _myBox.get("All_Expenses") ?? [];

    List<ExpensesItem> allExpense = [];

    for (int i = 0; i < savedExpense.length; i++) {
      try {
        if (savedExpense[i] is Map<String, dynamic>) {
          // New format with enhanced structure
          allExpense.add(ExpensesItem.fromMap(savedExpense[i]));
        } else if (savedExpense[i] is List) {
          // Legacy format - convert to new format
          List<dynamic> legacyExpense = savedExpense[i];
          if (legacyExpense.length >= 3) {
            final legacyItem = ExpensesItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: legacyExpense[0] ?? '',
              amount: (legacyExpense[1] is String) 
                  ? double.tryParse(legacyExpense[1]) ?? 0.0 
                  : (legacyExpense[1] is num) 
                      ? (legacyExpense[1] as num).toDouble() 
                      : 0.0,
              dateTime: legacyExpense[2] is DateTime 
                  ? legacyExpense[2] 
                  : DateTime.now(),
            );
            allExpense.add(legacyItem);
          }
        }
      } catch (e) {
        // Log error silently in production
        continue;
      }
    }
    return allExpense;
  }

  void saveExpense(ExpensesItem expense) {
    List<ExpensesItem> currentExpenses = readData();
    currentExpenses.add(expense);
    saveData(currentExpenses);
  }

  void updateExpense(ExpensesItem expense) {
    List<ExpensesItem> currentExpenses = readData();
    final index = currentExpenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      currentExpenses[index] = expense;
      saveData(currentExpenses);
    }
  }

  void deleteExpense(String expenseId) {
    List<ExpensesItem> currentExpenses = readData();
    currentExpenses.removeWhere((e) => e.id == expenseId);
    saveData(currentExpenses);
  }

  void clearAllData() {
    _myBox.clear();
  }
}
