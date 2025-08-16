import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double dailyBudget;

  @HiveField(2)
  String currency;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime lastUpdated;

  UserProfile({
    required this.name,
    required this.dailyBudget,
    this.currency = 'USD',
    DateTime? createdAt,
    DateTime? lastUpdated,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

  // Get currency symbol
  String get currencySymbol {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      default:
        return '\$';
    }
  }

  // Format amount with currency
  String formatAmount(double amount) {
    return '${currencySymbol}${amount.toStringAsFixed(2)}';
  }

  // Copy with updates
  UserProfile copyWith({
    String? name,
    double? dailyBudget,
    String? currency,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      currency: currency ?? this.currency,
      createdAt: createdAt,
      lastUpdated: DateTime.now(),
    );
  }
}
