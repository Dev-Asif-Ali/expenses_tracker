import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';
import 'package:hive/hive.dart';

class HiveDataBase {
  final _myBox = Hive.box("expenses_database");

  void saveData(List<ExpensesItem> allExpense) {
    List<List<dynamic>> allExpenseFormatted = [];
    for (var expense in allExpense) {
      List<dynamic> expenseFormatted = [
        expense.name,
        expense.amount,
        expense.dateTime,
      ];
      allExpenseFormatted.add(expenseFormatted);
    }
    _myBox.put("All_Expenses", allExpenseFormatted);
  }

  List<ExpensesItem> readData() {
    List savedExpense = _myBox.get("All_Expenses") ?? [];

    List<ExpensesItem> allExpense = [];

    for (int i = 0; i < savedExpense.length; i++) {
      String name = savedExpense[i][0];
      String amount = savedExpense[i][1];
      DateTime dateTime = savedExpense[i][2];

      ExpensesItem expense =
          ExpensesItem(
            name: name, 
            amount: amount, 
            dateTime: dateTime,
            );
            allExpense.add(expense);
    }
    return allExpense;
  }
}
