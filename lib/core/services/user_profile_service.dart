import 'package:hive_flutter/hive_flutter.dart';
import 'package:expenses_tracker/core/models/user_profile.dart';
import 'package:expenses_tracker/features/track_expenses/domain/entities/expenses_item.dart';

class UserProfileService {
  static const String _boxName = 'UserProfile';
  static const String _profileKey = 'current_profile';
  
  late Box<UserProfile> _box;
  
  // Singleton pattern
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  // Initialize the service
  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    
    _box = await Hive.openBox<UserProfile>(_boxName);
  }

  // Check if user profile exists
  bool get hasProfile => _box.get(_profileKey) != null;

  // Get current user profile
  UserProfile? get currentProfile => _box.get(_profileKey);
  
  // Alias for currentProfile to maintain compatibility
  UserProfile? get userProfile => currentProfile;

  // Save or update user profile
  Future<void> saveProfile(UserProfile profile) async {
    await _box.put(_profileKey, profile);
  }

  // Update existing profile
  Future<void> updateProfile({
    String? name,
    double? dailyBudget,
    String? currency,
  }) async {
    final current = currentProfile;
    if (current != null) {
      final updated = current.copyWith(
        name: name,
        dailyBudget: dailyBudget,
        currency: currency,
      );
      await saveProfile(updated);
    }
  }

  // Delete user profile
  Future<void> deleteProfile() async {
    await _box.delete(_profileKey);
  }

  // Get daily spending for today
  double getDailySpending(List<ExpensesItem> expenses) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return expenses
        .where((expense) => 
            expense.dateTime.isAfter(startOfDay) && 
            expense.dateTime.isBefore(endOfDay))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Check if daily budget is exceeded
  bool isDailyBudgetExceeded(List<ExpensesItem> expenses) {
    final profile = currentProfile;
    if (profile == null) return false;
    
    final dailySpending = getDailySpending(expenses);
    return dailySpending > profile.dailyBudget;
  }

  // Get remaining daily budget
  double getRemainingDailyBudget(List<ExpensesItem> expenses) {
    final profile = currentProfile;
    if (profile == null) return 0.0;
    
    final dailySpending = getDailySpending(expenses);
    return (profile.dailyBudget - dailySpending).clamp(0.0, double.infinity);
  }

  // Get daily budget percentage used
  double getDailyBudgetPercentage(List<ExpensesItem> expenses) {
    final profile = currentProfile;
    if (profile == null || profile.dailyBudget == 0) return 0.0;
    
    final dailySpending = getDailySpending(expenses);
    return (dailySpending / profile.dailyBudget * 100).clamp(0.0, 100.0);
  }

  // Close the service
  Future<void> close() async {
    await _box.close();
  }
}
