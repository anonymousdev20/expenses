import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import 'expense_provider.dart';

class BudgetProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<Budget> _budgets = <Budget>[];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and load budgets
  Future<void> initialize() async {
    await loadBudgets();
  }

  Future<void> loadBudgets() async {
    _setLoading(true);
    try {
      _budgets = await _databaseService.getAllBudgets() as List<Budget>;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addBudget(Budget budget) async {
    _setLoading(true);
    try {
      await _databaseService.insertBudget(budget);
      _budgets.add(budget);
      _budgets.sort((a, b) => a.startDate.compareTo(b.startDate));
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBudget(Budget budget) async {
    _setLoading(true);
    try {
      await _databaseService.updateBudget(budget);
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        _budgets.sort((a, b) => a.startDate.compareTo(b.startDate));
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteBudget(String id) async {
    _setLoading(true);
    try {
      await _databaseService.deleteBudget(id);
      _budgets.removeWhere((b) => b.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Budget? getBudgetById(String id) {
    try {
      return _budgets.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  Budget? getBudgetByCategory(String categoryId) {
    try {
      return _budgets.firstWhere((b) => 
        b.categoryId == categoryId && 
        b.isActive &&
        b.startDate.isBefore(DateTime.now()) &&
        b.endDate.isAfter(DateTime.now())
      );
    } catch (e) {
      return null;
    }
  }

  // Update budget spent amount based on expenses
  Future<void> updateBudgetSpentAmounts(List<Expense> expenses) async {
    for (final budget in _budgets) {
      final spent = expenses
          .where((e) => e.category == budget.categoryId)
          .where((e) => e.date.isAfter(budget.startDate) && e.date.isBefore(budget.endDate))
          .fold(0.0, (sum, expense) => sum + expense.amount);
      
      if (budget.spent != spent) {
        final updatedBudget = budget.copyWith(spent: spent);
        await updateBudget(updatedBudget);
      }
    }
  }

  // Get budget statistics
  List<Budget> getActiveBudgets() {
    final now = DateTime.now();
    return _budgets.where((b) => 
      b.isActive &&
      b.startDate.isBefore(now) &&
      b.endDate.isAfter(now)
    ).toList();
  }

  List<Budget> getOverBudgetBudgets() {
    return getActiveBudgets().where((b) => b.isOverBudget).toList();
  }

  List<Budget> getNearLimitBudgets() {
    return getActiveBudgets().where((b) => b.isNearLimit && !b.isOverBudget).toList();
  }

  double getTotalBudgetSpent() {
    return _budgets.fold(0.0, (sum, budget) => sum + budget.spent);
  }

  double getTotalBudgetAmount() {
    return _budgets.fold(0.0, (sum, budget) => sum + budget.amount);
  }

  double getTotalBudgetRemaining() {
    return _budgets.fold(0.0, (sum, budget) => sum + budget.remaining);
  }

  // Budget alerts
  List<String> getBudgetAlerts() {
    final List<String> alerts = [];
    
    for (final budget in getActiveBudgets()) {
      if (budget.isOverBudget) {
        alerts.add('⚠️ ${budget.categoryId} is over budget by ${budget.spent - budget.amount}');
      } else if (budget.isNearLimit) {
        alerts.add('⚡ ${budget.categoryId} is ${100 - budget.percentageUsed}% away from budget limit');
      }
    }
    
    return alerts;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadBudgets();
  }

  // Get budget by period
  List<Budget> getBudgetsByPeriod(String period) {
    return _budgets.where((b) => b.period == period).toList();
  }

  // Getters for total budget statistics
  double get totalBudgetAmount {
    return _budgets.fold(0.0, (sum, budget) => sum + budget.amount);
  }

  double get totalSpentAmount {
    return _budgets.fold(0.0, (sum, budget) => sum + budget.spent);
  }

  // Get active budgets
  List<Budget> get activeBudgets {
    return _budgets.where((budget) => budget.isActive).toList();
  }

  // Get over budget budgets
  List<Budget> get overBudgetBudgets {
    return _budgets.where((budget) => budget.isOverBudget).toList();
  }

  // Get near limit budgets
  List<Budget> get nearLimitBudgets {
    return _budgets.where((budget) => budget.isNearLimit).toList();
  }

  // Get budget progress for a category
  double getBudgetProgress(String categoryId) {
    final budget = getBudgetByCategory(categoryId);
    if (budget == null) return 0.0;
    return budget.percentageUsed;
  }

  // Check if category has budget
  bool hasBudget(String categoryId) {
    return getBudgetByCategory(categoryId) != null;
  }

  // Get remaining budget for category
  double getRemainingBudget(String categoryId) {
    final budget = getBudgetByCategory(categoryId);
    if (budget == null) return 0.0;
    return budget.remaining;
  }
}
