import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/budget.dart';

/// Web-compatible storage service using shared_preferences (localStorage on web).
/// Replaces the sqflite-based implementation which does not work on Flutter Web.
class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();

  DatabaseService._();

  static const String _expensesKey = 'expenses';
  static const String _categoriesKey = 'categories';
  static const String _budgetsKey = 'budgets';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _storage async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ─── Initialisation ────────────────────────────────────────────────────────

  /// Call once at app start to seed default categories if none exist.
  Future<void> init() async {
    final categories = await getAllCategories();
    if (categories.isEmpty) {
      final defaults = [
        ...DefaultCategories.getDefaultExpenseCategories(),
        ...DefaultCategories.getDefaultIncomeCategories(),
      ];
      for (final cat in defaults) {
        await insertCategory(cat);
      }
    }
  }

  // ─── Generic helpers ───────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _readList(String key) async {
    final prefs = await _storage;
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> list) async {
    final prefs = await _storage;
    await prefs.setString(key, jsonEncode(list));
  }

  // ─── Expense operations ────────────────────────────────────────────────────

  Future<String> insertExpense(Expense expense) async {
    final list = await _readList(_expensesKey);
    list.add(expense.toMap());
    await _writeList(_expensesKey, list);
    return expense.id;
  }

  Future<List<Expense>> getAllExpenses() async {
    final list = await _readList(_expensesKey);
    final expenses = list.map((m) => Expense.fromMap(m)).toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  Future<List<Expense>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    final all = await getAllExpenses();
    return all
        .where((e) =>
            !e.date.isBefore(start) && !e.date.isAfter(end))
        .toList();
  }

  Future<List<Expense>> getExpensesByCategory(String category) async {
    final all = await getAllExpenses();
    return all.where((e) => e.category == category).toList();
  }

  Future<Expense?> getExpenseById(String id) async {
    final all = await getAllExpenses();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<int> updateExpense(Expense expense) async {
    final list = await _readList(_expensesKey);
    final idx = list.indexWhere((m) => m['id'] == expense.id);
    if (idx == -1) return 0;
    list[idx] = expense.toMap();
    await _writeList(_expensesKey, list);
    return 1;
  }

  Future<int> deleteExpense(String id) async {
    final list = await _readList(_expensesKey);
    final before = list.length;
    list.removeWhere((m) => m['id'] == id);
    await _writeList(_expensesKey, list);
    return before - list.length;
  }

  // ─── Category operations ───────────────────────────────────────────────────

  Future<String> insertCategory(Category category) async {
    final list = await _readList(_categoriesKey);
    list.add(category.toMap());
    await _writeList(_categoriesKey, list);
    return category.id;
  }

  Future<List<Category>> getAllCategories() async {
    final list = await _readList(_categoriesKey);
    final categories = list.map((m) => Category.fromMap(m)).toList();
    categories.sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  Future<Category?> getCategoryById(String id) async {
    final all = await getAllCategories();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<int> updateCategory(Category category) async {
    final list = await _readList(_categoriesKey);
    final idx = list.indexWhere((m) => m['id'] == category.id);
    if (idx == -1) return 0;
    list[idx] = category.toMap();
    await _writeList(_categoriesKey, list);
    return 1;
  }

  Future<int> deleteCategory(String id) async {
    final list = await _readList(_categoriesKey);
    final before = list.length;
    list.removeWhere((m) => m['id'] == id);
    await _writeList(_categoriesKey, list);
    return before - list.length;
  }

  // ─── Budget operations ─────────────────────────────────────────────────────

  Future<String> insertBudget(Budget budget) async {
    final list = await _readList(_budgetsKey);
    list.add(budget.toMap());
    await _writeList(_budgetsKey, list);
    return budget.id;
  }

  Future<List<Budget>> getAllBudgets() async {
    final list = await _readList(_budgetsKey);
    final budgets = list
        .map((m) => Budget.fromMap(m))
        .where((b) => b.isActive)
        .toList();
    budgets.sort((a, b) => b.startDate.compareTo(a.startDate));
    return budgets;
  }

  Future<Budget?> getBudgetById(String id) async {
    final list = await _readList(_budgetsKey);
    try {
      return Budget.fromMap(list.firstWhere((m) => m['id'] == id));
    } catch (_) {
      return null;
    }
  }

  Future<Budget?> getBudgetByCategory(String categoryId) async {
    final all = await getAllBudgets();
    try {
      return all.firstWhere(
          (b) => b.categoryId == categoryId && b.isActive);
    } catch (_) {
      return null;
    }
  }

  Future<int> updateBudget(Budget budget) async {
    final list = await _readList(_budgetsKey);
    final idx = list.indexWhere((m) => m['id'] == budget.id);
    if (idx == -1) return 0;
    list[idx] = budget.toMap();
    await _writeList(_budgetsKey, list);
    return 1;
  }

  Future<int> deleteBudget(String id) async {
    final list = await _readList(_budgetsKey);
    final before = list.length;
    list.removeWhere((m) => m['id'] == id);
    await _writeList(_budgetsKey, list);
    return before - list.length;
  }

  // ─── Analytics ─────────────────────────────────────────────────────────────

  Future<double> getTotalExpenses(DateTime start, DateTime end) async {
    final expenses = await getExpensesByDateRange(start, end);
    return expenses
        .where((e) => !e.isIncome)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  Future<double> getTotalIncome(DateTime start, DateTime end) async {
    final expenses = await getExpensesByDateRange(start, end);
    return expenses
        .where((e) => e.isIncome)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  Future<Map<String, double>> getExpensesByCategorySummary(
      DateTime start, DateTime end) async {
    final expenses = await getExpensesByDateRange(start, end);
    final Map<String, double> result = {};
    for (final e in expenses.where((e) => !e.isIncome)) {
      result[e.category] = (result[e.category] ?? 0.0) + e.amount;
    }
    return result;
  }

  // ─── Maintenance ───────────────────────────────────────────────────────────

  Future<void> clearAllData() async {
    final prefs = await _storage;
    await prefs.remove(_expensesKey);
    await prefs.remove(_budgetsKey);
    // Keep default categories; remove only custom ones
    final cats = await _readList(_categoriesKey);
    final defaults = cats.where((m) => (m['isDefault'] ?? 0) == 1).toList();
    await _writeList(_categoriesKey, defaults);
  }

  Future<void> close() async {
    // No-op for shared_preferences — nothing to close.
  }
}
