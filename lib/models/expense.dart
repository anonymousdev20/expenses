import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final String notes;
  final List<String> tags;
  final String? location;
  final String? receiptImagePath;
  final bool isRecurring;
  final String? recurringPattern;
  final DateTime? recurringEndDate;
  final bool isIncome;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.paymentMethod,
    this.notes = '',
    this.tags = const [],
    this.location,
    this.receiptImagePath,
    this.isRecurring = false,
    this.recurringPattern,
    this.recurringEndDate,
    this.isIncome = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  // For database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'tags': tags.join(','),
      'location': location,
      'receiptImagePath': receiptImagePath,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringPattern': recurringPattern,
      'recurringEndDate': recurringEndDate?.toIso8601String(),
      'isIncome': isIncome ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount']?.toDouble() ?? 0.0,
      category: map['category'],
      date: DateTime.parse(map['date']),
      paymentMethod: map['paymentMethod'],
      notes: map['notes'] ?? '',
      tags: map['tags'] != null ? (map['tags'] as String).split(',') : [],
      location: map['location'],
      receiptImagePath: map['receiptImagePath'],
      isRecurring: (map['isRecurring'] ?? 0) == 1,
      recurringPattern: map['recurringPattern'],
      recurringEndDate: map['recurringEndDate'] != null 
          ? DateTime.parse(map['recurringEndDate']) 
          : null,
      isIncome: (map['isIncome'] ?? 0) == 1,
    );
  }

  Expense copyWith({
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? paymentMethod,
    String? notes,
    List<String>? tags,
    String? location,
    String? receiptImagePath,
    bool? isRecurring,
    String? recurringPattern,
    DateTime? recurringEndDate,
    bool? isIncome,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
      isIncome: isIncome ?? this.isIncome,
    );
  }

  @override
  String toString() {
    return 'Expense{id: $id, title: $title, amount: $amount, category: $category, date: $date}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.category == category &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        amount.hashCode ^
        category.hashCode ^
        date.hashCode;
  }
}
