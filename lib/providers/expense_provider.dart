import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<Expense> _expenses = <Expense>[];
  List<Expense> _filteredExpenses = <Expense>[];
  bool _isLoading = false;
  String? _error;
  
  // Filters
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;
  bool? _isIncome;
  String _searchQuery = '';

  // Getters
  List<Expense> get expenses => _filteredExpenses.isEmpty ? _expenses : _filteredExpenses;
  List<Expense> get allExpenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Filter getters
  String? get selectedCategory => _selectedCategory;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  double? get minAmount => _minAmount;
  double? get maxAmount => _maxAmount;
  bool? get isIncome => _isIncome;
  String get searchQuery => _searchQuery;

  // Initialize and load expenses
  Future<void> initialize() async {
    await loadExpenses();
  }

  Future<void> loadExpenses() async {
    _setLoading(true);
    try {
      _expenses = await _databaseService.getAllExpenses() as List<Expense>;
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addExpense(Expense expense) async {
    _setLoading(true);
    try {
      await _databaseService.insertExpense(expense);
      _expenses.insert(0, expense);
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateExpense(Expense expense) async {
    _setLoading(true);
    try {
      await _databaseService.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        _applyFilters();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExpense(String id) async {
    _setLoading(true);
    try {
      await _databaseService.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteMultipleExpenses(List<String> ids) async {
    _setLoading(true);
    try {
      for (final id in ids) {
        await _databaseService.deleteExpense(id);
      }
      _expenses.removeWhere((e) => ids.contains(e.id));
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Filter methods
  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void setDateRangeFilter(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
  }

  void setAmountRangeFilter(double? min, double? max) {
    _minAmount = min;
    _maxAmount = max;
    _applyFilters();
  }

  void setIncomeFilter(bool? income) {
    _isIncome = income;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void clearFilters() {
    _selectedCategory = null;
    _startDate = null;
    _endDate = null;
    _minAmount = null;
    _maxAmount = null;
    _isIncome = null;
    _searchQuery = '';
    _filteredExpenses = [];
    notifyListeners();
  }

  void _applyFilters() {
    _filteredExpenses = _expenses.where((expense) {
      // Category filter
      if (_selectedCategory != null && expense.category != _selectedCategory) {
        return false;
      }

      // Date range filter
      if (_startDate != null && expense.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && expense.date.isAfter(_endDate!)) {
        return false;
      }

      // Amount range filter
      if (_minAmount != null && expense.amount < _minAmount!) {
        return false;
      }
      if (_maxAmount != null && expense.amount > _maxAmount!) {
        return false;
      }

      // Income filter
      if (_isIncome != null && expense.isIncome != _isIncome) {
        return false;
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery;
        if (!expense.title.toLowerCase().contains(query) &&
            !expense.notes.toLowerCase().contains(query) &&
            !expense.category.toLowerCase().contains(query) &&
            !expense.paymentMethod.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // Analytics methods
  double getTotalExpenses({DateTime? startDate, DateTime? endDate}) {
    var expenses = _expenses.where((e) => !e.isIncome);
    
    if (startDate != null) {
      expenses = expenses.where((e) => e.date.isAfter(startDate));
    }
    if (endDate != null) {
      expenses = expenses.where((e) => e.date.isBefore(endDate));
    }
    
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double getTotalIncome({DateTime? startDate, DateTime? endDate}) {
    var expenses = _expenses.where((e) => e.isIncome);
    
    if (startDate != null) {
      expenses = expenses.where((e) => e.date.isAfter(startDate));
    }
    if (endDate != null) {
      expenses = expenses.where((e) => e.date.isBefore(endDate));
    }
    
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double getBalance({DateTime? startDate, DateTime? endDate}) {
    return getTotalIncome(startDate: startDate, endDate: endDate) - 
           getTotalExpenses(startDate: startDate, endDate: endDate);
  }

  Map<String, double> getExpensesByCategory({DateTime? startDate, DateTime? endDate}) {
    final Map<String, double> categoryExpenses = {};
    var expenses = _expenses.where((e) => !e.isIncome);
    
    if (startDate != null) {
      expenses = expenses.where((e) => e.date.isAfter(startDate));
    }
    if (endDate != null) {
      expenses = expenses.where((e) => e.date.isBefore(endDate));
    }
    
    for (final expense in expenses) {
      categoryExpenses[expense.category] = 
          (categoryExpenses[expense.category] ?? 0.0) + expense.amount;
    }
    
    return categoryExpenses;
  }

  List<Expense> getRecentExpenses({int limit = 10}) {
    return _expenses
        .where((e) => !e.isIncome)
        .take(limit)
        .toList();
  }

  List<Expense> getRecurringExpenses() {
    return _expenses.where((e) => e.isRecurring).toList();
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
    await loadExpenses();
  }
}
