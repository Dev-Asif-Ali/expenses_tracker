import 'package:expenses_tracker/features/track_expenses/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expenses_tracker/features/track_expenses/data/repositories/expenses_repo_impl.dart';
import 'package:expenses_tracker/features/track_expenses/domain/usecases/add_expense.dart';
import 'package:expenses_tracker/features/track_expenses/domain/usecases/delete_expense.dart';
import 'package:expenses_tracker/features/track_expenses/domain/usecases/get_expenses.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/bloc/expense_bloc.dart';
import 'package:expenses_tracker/features/track_expenses/presentation/pages/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox('Expenses_Database');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ExpenseRepositoryImpl expenseRepository = ExpenseRepositoryImpl(); 
    return BlocProvider(
      create: (context) => ExpenseBloc(
        getExpenses: GetExpenses(expenseRepository),
        addExpense: AddExpense(expenseRepository),
        deleteExpense: DeleteExpense(expenseRepository),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expenses Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen(expenseRepository: expenseRepository,),
      ),
    );
  }
}
