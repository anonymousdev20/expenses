import 'package:uuid/uuid.dart';

class Budget {
  final String id;
  final String categoryId;
  final double amount;
  final double spent;
  final String period; // 'monthly', 'weekly', 'yearly'
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    String? id,
    required this.categoryId,
    required this.amount,
    this.spent = 0.0,
    this.period = 'monthly',
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4(),
       createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  double get remaining => amount - spent;
  double get percentageUsed => amount > 0 ? (spent / amount) * 100 : 0;
  bool get isOverBudget => spent > amount;
  bool get isNearLimit => percentageUsed >= 80;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'spent': spent,
      'period': period,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categoryId: map['categoryId'],
      amount: map['amount']?.toDouble() ?? 0.0,
      spent: map['spent']?.toDouble() ?? 0.0,
      period: map['period'] ?? 'monthly',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      isActive: (map['isActive'] ?? 1) == 1,
    );
  }

  Budget copyWith({
    String? categoryId,
    double? amount,
    double? spent,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return Budget(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  // Additional getters for compatibility
  double get spentAmount => spent;
  
  double get overBudgetAmount {
    if (spent <= amount) return 0.0;
    return spent - amount;
  }

  @override
  String toString() {
    return 'Budget{id: $id, categoryId: $categoryId, amount: $amount, spent: $spent, period: $period}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.amount == amount &&
        other.spent == spent;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        categoryId.hashCode ^
        amount.hashCode ^
        spent.hashCode;
  }
}
