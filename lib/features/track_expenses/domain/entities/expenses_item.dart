import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 2)
enum ExpenseCategory {
  @HiveField(0)
  food,
  @HiveField(1)
  transport,
  @HiveField(2)
  entertainment,
  @HiveField(3)
  shopping,
  @HiveField(4)
  health,
  @HiveField(5)
  education,
  @HiveField(6)
  utilities,
  @HiveField(7)
  housing,
  @HiveField(8)
  other
}

@HiveType(typeId: 3)
class ExpensesItem extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final DateTime dateTime;
  @HiveField(4)
  final ExpenseCategory category;
  @HiveField(5)
  final List<String> tags;
  @HiveField(6)
  final String? note;
  @HiveField(7)
  final bool isRecurring;
  @HiveField(8)
  final String? recurringPeriod; // daily, weekly, monthly, yearly

  const ExpensesItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.dateTime,
    this.category = ExpenseCategory.other,
    this.tags = const [],
    this.note,
    this.isRecurring = false,
    this.recurringPeriod,
  });

  ExpensesItem copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? dateTime,
    ExpenseCategory? category,
    List<String>? tags,
    String? note,
    bool? isRecurring,
    String? recurringPeriod,
  }) {
    return ExpensesItem(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPeriod: recurringPeriod ?? this.recurringPeriod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'category': category.name,
      'tags': tags,
      'note': note,
      'isRecurring': isRecurring,
      'recurringPeriod': recurringPeriod,
    };
  }

  factory ExpensesItem.fromMap(Map<String, dynamic> map) {
    return ExpensesItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      amount: (map['amount'] is int) ? (map['amount'] as int).toDouble() : map['amount'] ?? 0.0,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ExpenseCategory.other,
      ),
      tags: List<String>.from(map['tags'] ?? []),
      note: map['note'],
      isRecurring: map['isRecurring'] ?? false,
      recurringPeriod: map['recurringPeriod'],
    );
  }

  @override
  List<Object?> get props => [id, name, amount, dateTime, category, tags, note, isRecurring, recurringPeriod];
}