import 'package:equatable/equatable.dart';

enum BudgetPeriod {
  daily,
  weekly,
  monthly,
  yearly
}

class Budget extends Equatable {
  final String id;
  final String name;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> categoryIds; // Empty means all categories
  final bool isActive;
  final String? note;

  const Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.categoryIds = const [],
    this.isActive = true,
    this.note,
  });

  Budget copyWith({
    String? id,
    String? name,
    double? amount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    bool? isActive,
    String? note,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryIds: categoryIds ?? this.categoryIds,
      isActive: isActive ?? this.isActive,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'period': period.name,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'categoryIds': categoryIds,
      'isActive': isActive,
      'note': note,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      amount: (map['amount'] is int) ? (map['amount'] as int).toDouble() : map['amount'] ?? 0.0,
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      categoryIds: List<String>.from(map['categoryIds'] ?? []),
      isActive: map['isActive'] ?? true,
      note: map['note'],
    );
  }

  @override
  List<Object?> get props => [id, name, amount, period, startDate, endDate, categoryIds, isActive, note];
}
