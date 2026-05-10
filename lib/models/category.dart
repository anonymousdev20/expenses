import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;
  final String color;
  final String icon;
  final String description;
  final bool isDefault;
  final double budgetLimit;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    String? id,
    required this.name,
    required this.color,
    required this.icon,
    this.description = '',
    this.isDefault = false,
    this.budgetLimit = 0.0,
  }) : id = id ?? const Uuid().v4(),
       createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'description': description,
      'isDefault': isDefault ? 1 : 0,
      'budgetLimit': budgetLimit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      icon: map['icon'],
      description: map['description'] ?? '',
      isDefault: (map['isDefault'] ?? 0) == 1,
      budgetLimit: map['budgetLimit']?.toDouble() ?? 0.0,
    );
  }

  Category copyWith({
    String? name,
    String? color,
    String? icon,
    String? description,
    bool? isDefault,
    double? budgetLimit,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      budgetLimit: budgetLimit ?? this.budgetLimit,
    );
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, color: $color, icon: $icon}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.color == color &&
        other.icon == icon;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        color.hashCode ^
        icon.hashCode;
  }
}

// Default categories for the app
class DefaultCategories {
  static const List<Map<String, String>> expenseCategories = [
    {'name': 'Food & Dining', 'color': '#FF6B6B', 'icon': '🍔'},
    {'name': 'Transportation', 'color': '#4ECDC4', 'icon': '🚗'},
    {'name': 'Shopping', 'color': '#45B7D1', 'icon': '🛍️'},
    {'name': 'Bills & Utilities', 'color': '#96CEB4', 'icon': '📄'},
    {'name': 'Entertainment', 'color': '#FFEAA7', 'icon': '🎮'},
    {'name': 'Health & Fitness', 'color': '#DDA0DD', 'icon': '🏃'},
    {'name': 'Education', 'color': '#98D8C8', 'icon': '📚'},
    {'name': 'Travel', 'color': '#FFB6C1', 'icon': '✈️'},
    {'name': 'Personal Care', 'color': '#87CEEB', 'icon': '💄'},
    {'name': 'Gifts & Donations', 'color': '#F0E68C', 'icon': '🎁'},
  ];

  static const List<Map<String, String>> incomeCategories = [
    {'name': 'Salary', 'color': '#2ECC71', 'icon': '💰'},
    {'name': 'Freelance', 'color': '#3498DB', 'icon': '💻'},
    {'name': 'Investments', 'color': '#9B59B6', 'icon': '📈'},
    {'name': 'Business', 'color': '#E67E22', 'icon': '🏢'},
    {'name': 'Other Income', 'color': '#1ABC9C', 'icon': '💵'},
  ];

  static List<Category> getDefaultExpenseCategories() {
    return expenseCategories.map((cat) => Category(
      name: cat['name']!,
      color: cat['color']!,
      icon: cat['icon']!,
      isDefault: true,
    )).toList();
  }

  static List<Category> getDefaultIncomeCategories() {
    return incomeCategories.map((cat) => Category(
      name: cat['name']!,
      color: cat['color']!,
      icon: cat['icon']!,
      isDefault: true,
    )).toList();
  }
}
