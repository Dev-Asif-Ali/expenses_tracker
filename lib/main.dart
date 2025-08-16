import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'core/notifications/notification_manager.dart';
import 'core/services/user_profile_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/models/user_profile.dart';
import 'features/onboarding/presentation/pages/onboarding_screen.dart';
import 'features/track_expenses/data/repositories/expenses_repo_impl.dart';
import 'features/track_expenses/domain/usecases/add_expense.dart';
import 'features/track_expenses/domain/usecases/delete_expense.dart';
import 'features/track_expenses/domain/usecases/get_expenses.dart';
import 'features/track_expenses/domain/entities/expenses_item.dart';
import 'features/track_expenses/domain/entities/expense_category_adapter.dart';
import 'features/track_expenses/domain/entities/expenses_item_adapter.dart';
import 'features/track_expenses/presentation/bloc/expense_bloc.dart';
import 'features/track_expenses/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive database
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    
    // Register Hive adapters
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ExpenseCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ExpensesItemAdapter());
    }
    
    await Hive.openBox('Expenses_Database');
    
    // Initialize user profile service
    final userProfileService = UserProfileService();
    await userProfileService.initialize();
    
    // Initialize notification system (non-blocking)
    _initializeNotifications();
    
    runApp(const MyApp());
  } catch (e) {
    // Run app even if initialization fails
    runApp(const MyApp());
  }
}

// Initialize notifications in background
Future<void> _initializeNotifications() async {
  try {
    final notificationManager = NotificationManager();
    await notificationManager.initialize();
    
    // Schedule default notifications
    await notificationManager.scheduleDailyReminder();
    await notificationManager.scheduleWeeklySummary();
    await notificationManager.scheduleMonthlySummary();
  } catch (e) {
    // Continue without notifications
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ExpenseRepositoryImpl expenseRepository = ExpenseRepositoryImpl(); 
    
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MultiProvider(
            providers: [
              BlocProvider(
                create: (context) => ExpenseBloc(
                  getExpenses: GetExpenses(expenseRepository),
                  addExpense: AddExpense(expenseRepository),
                  deleteExpense: DeleteExpense(expenseRepository),
                ),
              ),
              Provider<UserProfileService>(
                create: (context) => UserProfileService(),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Expenses Tracker Pro',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: _buildHomeScreen(expenseRepository),
              // Production optimizations
              showPerformanceOverlay: false,
              showSemanticsDebugger: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeScreen(ExpenseRepositoryImpl expenseRepository) {
    final userProfileService = UserProfileService();
    
    if (userProfileService.hasProfile) {
      return const SplashScreen();
    } else {
      return const OnboardingScreen();
    }
  }
}
