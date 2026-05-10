import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../models/category.dart' as models;
import '../providers/category_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/add_category_dialog.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    await categoryProvider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expense Categories'),
            Tab(text: 'Income Categories'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCategory,
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (categoryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading categories',
                    style: AppTheme.titleStyle.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categoryProvider.error!,
                    style: AppTheme.bodyStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCategories,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(categoryProvider.expenseCategories, false),
              _buildCategoryList(categoryProvider.incomeCategories, true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(List<models.Category> categories, bool isIncome) {
    final filteredCategories = categories.where((c) => !c.isDefault).toList();
    
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isIncome ? Icons.account_balance : Icons.shopping_cart,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${isIncome ? 'income' : 'expense'} categories',
              style: AppTheme.titleStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add custom categories to organize your transactions',
              style: AppTheme.bodyStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _addCategory(isIncome: isIncome),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Default Categories
            if (filteredCategories.isNotEmpty) ...[
              Text(
                'Default Categories',
                style: AppTheme.subtitleStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: categories.where((c) => c.isDefault).length,
                itemBuilder: (context, index) {
                  final category = categories.where((c) => c.isDefault).elementAt(index);
                  return CategoryCard(
                    category: category,
                    isDefault: true,
                    onTap: () => _viewCategoryDetails(category),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
            
            // Custom Categories
            if (filteredCategories.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custom Categories',
                    style: AppTheme.subtitleStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _addCategory(isIncome: isIncome),
                    child: const Text('Add New'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return CategoryCard(
                    category: category,
                    isDefault: false,
                    onTap: () => _viewCategoryDetails(category),
                    onEdit: () => _editCategory(category),
                    onDelete: () => _deleteCategory(category),
                  );
                },
              ),
            ] else ...[
              // No custom categories
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No custom categories yet',
                      style: AppTheme.subtitleStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create custom categories to better organize your transactions',
                      style: AppTheme.bodyStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _addCategory(isIncome: isIncome),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Category'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addCategory({bool? isIncome}) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        isIncome: isIncome ?? false,
        onCategoryAdded: (category) async {
          try {
            final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
            await categoryProvider.addCategory(category);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Category added successfully'),
                  backgroundColor: AppTheme.success,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error adding category: $e'),
                  backgroundColor: AppTheme.lightError,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _editCategory(models.Category category) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        category: category,
        isIncome: _isIncomeCategory(category),
        onCategoryAdded: (updatedCategory) async {
          try {
            final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
            await categoryProvider.updateCategory(updatedCategory);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Category updated successfully'),
                  backgroundColor: AppTheme.success,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating category: $e'),
                  backgroundColor: AppTheme.lightError,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteCategory(models.Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
        await categoryProvider.deleteCategory(category.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category deleted successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting category: $e'),
              backgroundColor: AppTheme.lightError,
            ),
          );
        }
      }
    }
  }

  void _viewCategoryDetails(models.Category category) {
    showDialog(
      context: context,
      builder: (context) => _CategoryDetailsDialog(category: category),
    );
  }

  bool _isIncomeCategory(models.Category category) {
    final incomeCategoryNames = [
      'Salary', 'Freelance', 'Investments', 'Business', 'Other Income'
    ];
    return incomeCategoryNames.contains(category.name);
  }
}

class _CategoryDetailsDialog extends StatelessWidget {
  final models.Category category;

  const _CategoryDetailsDialog({required this.category});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(
            _getCategoryIcon(category.name),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.name,
              style: AppTheme.titleStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (category.description.isNotEmpty) ...[
            Text(
              'Description',
              style: AppTheme.subtitleStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.description,
              style: AppTheme.bodyStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          Text(
            'Color',
            style: AppTheme.subtitleStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(int.parse(category.color.replaceAll('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                category.color,
                style: AppTheme.bodyStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          
          if (category.budgetLimit > 0) ...[
            const SizedBox(height: 16),
            Text(
              'Budget Limit',
              style: AppTheme.subtitleStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${category.budgetLimit.toStringAsFixed(2)}',
              style: AppTheme.bodyStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          Text(
            'Type',
            style: AppTheme.subtitleStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.isDefault ? 'Default Category' : 'Custom Category',
            style: AppTheme.bodyStyle.copyWith(
              color: category.isDefault 
                  ? AppTheme.success 
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _getCategoryIcon(String categoryName) {
    final icons = {
      'Food & Dining': '🍔',
      'Transportation': '🚗',
      'Shopping': '🛍️',
      'Bills & Utilities': '📄',
      'Entertainment': '🎮',
      'Health & Fitness': '🏃',
      'Education': '📚',
      'Travel': '✈️',
      'Personal Care': '💄',
      'Gifts & Donations': '🎁',
      'Salary': '💰',
      'Freelance': '💻',
      'Investments': '📈',
      'Business': '🏢',
      'Other Income': '💵',
    };
    return icons[categoryName] ?? '💳';
  }
}
