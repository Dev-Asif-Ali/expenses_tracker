import 'dart:developer';
import 'package:expenses_tracker/features/track_expenses/data/repositories/expenses_repo_impl.dart';
import 'package:expenses_tracker/features/track_expenses/domain/usecases/add_expense.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/widgets/expense_sumamry.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/widgets/expense_tile.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/bloc/expense_bloc.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/bloc/expense_event.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/bloc/expense_state.dart';
import '../../domain/entities/expenses_item.dart';

class MyHomePage extends StatefulWidget {
  final ExpenseRepositoryImpl repository;

  const MyHomePage({Key? key, required this.repository}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ExpenseBloc _expenseBloc;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _expenseBloc = BlocProvider.of<ExpenseBloc>(context);
    _expenseBloc.add(FetchExpenses());
  }

  @override
  void dispose() {
    _expenseBloc.close();
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          else if(state is ExpensesDeleted){
            setState(() {
              
            });
          }
        },
        builder: (context, state) {
          if (state is ExpensesLoaded || state is ExpensesAdded) {
            final expenses = state is ExpensesLoaded ? state.expenses : (state as ExpensesAdded).expenses;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // const SizedBox(height: 50),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .43,
                    child: ExpenseSummary(
                      startOfWeek: widget.repository.startOfWeek(),
                      repository: widget.repository,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return ExpenseTile(
                        name: expense.name,
                        amount: expense.amount,
                        dateTime: expense.dateTime, deletedTapped: (_) {  
                          _expenseBloc.deleteExpense(expenses[index]);
                            setState(() {});
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          } else if (state is ExpenseError) {
            return Center(
              child: Text(state.message),
            );
          } else if(state is ExpensesLoading){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          else{
            return const Center(
              child: Text('Default State'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Expense For'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(hintText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _saveExpense,
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _saveExpense() {
    final String name = nameController.text;
    final String amount = amountController.text;

    if (name.isNotEmpty && amount.isNotEmpty) {
      final newExpense = ExpensesItem(
        name: name,
        amount: amount,
        dateTime: DateTime.now(),
      );

      _expenseBloc.add(AddExpenseEvent(newExpense));
      setState(() {});
      nameController.clear();
      amountController.clear();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid expense details.'),
        ),
      );
    }
  }
}
