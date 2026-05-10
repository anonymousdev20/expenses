import 'package:flutter/foundation.dart';
import '../models/category.dart' as models;
import '../services/database_service.dart';

class CategoryProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<models.Category> _categories = <models.Category>[];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<models.Category> get categories => _categories;
  List<models.Category> get expenseCategories => _categories.where((c) => !models.DefaultCategories.getDefaultIncomeCategories().any((dc) => dc.name == c.name)).toList();
  List<models.Category> get incomeCategories => _categories.where((c) => models.DefaultCategories.getDefaultIncomeCategories().any((dc) => dc.name == c.name)).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and load categories
  Future<void> initialize() async {
    await loadCategories();
  }

  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await _databaseService.getAllCategories() as List<models.Category>;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCategory(models.Category category) async {
    _setLoading(true);
    try {
      await _databaseService.insertCategory(category);
      _categories.add(category);
      _categories.sort((a, b) => a.name.compareTo(b.name));
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCategory(models.Category category) async {
    _setLoading(true);
    try {
      await _databaseService.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        _categories.sort((a, b) => a.name.compareTo(b.name));
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCategory(String id) async {
    _setLoading(true);
    try {
      await _databaseService.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  models.Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  models.Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((c) => c.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  List<models.Category> searchCategories(String query) {
    if (query.isEmpty) return _categories;
    
    return _categories.where((category) =>
      category.name.toLowerCase().contains(query.toLowerCase()) ||
      category.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
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
    await loadCategories();
  }

  // Get category statistics
  Map<String, int> getCategoryUsageCount(List<String> categoryIds) {
    final Map<String, int> usageCount = {};
    for (final categoryId in categoryIds) {
      usageCount[categoryId] = 0; // This would need to be implemented with expense data
    }
    return usageCount;
  }

  // Get categories with budget limits
  List<models.Category> getCategoriesWithBudgets() {
    return _categories.where((c) => c.budgetLimit > 0).toList();
  }
}
