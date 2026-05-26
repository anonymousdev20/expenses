import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/budget.dart';
import '../models/category.dart' as models;
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/budget_card.dart';
import '../widgets/add_budget_dialog.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    await Future.wait([
      budgetProvider.refresh(),
      categoryProvider.refresh(),
      expenseProvider.refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.headerGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Budgets',
                            style: AppTheme.titleStyle.copyWith(
                                color: Colors.white, fontSize: 20)),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: _addBudget,
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    tabs: const [
                      Tab(text: 'Active Budgets'),
                      Tab(text: 'Budget Analysis'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer3<BudgetProvider, CategoryProvider, ExpenseProvider>(
              builder: (context, budgetProvider, categoryProvider, expenseProvider, child) {
                if (budgetProvider.isLoading || categoryProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (budgetProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 16),
                        Text('Error loading budgets',
                            style: AppTheme.titleStyle.copyWith(
                                color: Theme.of(context).colorScheme.error)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                      ],
                    ),
                  );
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveBudgets(budgetProvider, categoryProvider),
                    _buildBudgetAnalysis(budgetProvider, categoryProvider, expenseProvider),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBudgets(BudgetProvider budgetProvider, CategoryProvider categoryProvider) {
    final activeBudgets = budgetProvider.activeBudgets;
    
    if (activeBudgets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No active budgets',
              style: AppTheme.titleStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create budgets to track your spending limits',
              style: AppTheme.bodyStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addBudget,
              icon: const Icon(Icons.add),
              label: const Text('Create Budget'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    'Total Budget',
                    '${AppConstants.currencySymbol}${NumberFormat('#,##,##0', 'en_IN').format(budgetProvider.totalBudgetAmount)}',
                    Icons.account_balance,
                    AppTheme.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOverviewCard(
                    'Total Spent',
                    '${AppConstants.currencySymbol}${NumberFormat('#,##,##0', 'en_IN').format(budgetProvider.totalSpentAmount)}',
                    Icons.money_off,
                    AppTheme.lightError,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    'Remaining',
                    '${AppConstants.currencySymbol}${NumberFormat('#,##,##0', 'en_IN').format(budgetProvider.totalBudgetAmount - budgetProvider.totalSpentAmount)}',
                    Icons.savings,
                    AppTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOverviewCard(
                    'Over Budget',
                    '${budgetProvider.overBudgetBudgets.length}',
                    Icons.warning,
                    AppTheme.lightError,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Budget Alerts
            if (budgetProvider.overBudgetBudgets.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightError.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.lightError.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: AppTheme.lightError,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Budget Alerts',
                          style: AppTheme.subtitleStyle.copyWith(
                            color: AppTheme.lightError,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...budgetProvider.overBudgetBudgets.map((budget) {
                      final category = categoryProvider.getCategoryById(budget.categoryId);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${category?.name ?? 'Unknown'}: Over budget by ${AppConstants.currencySymbol}${NumberFormat('#,##,##0.00', 'en_IN').format(budget.overBudgetAmount)}',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.lightError,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            if (budgetProvider.nearLimitBudgets.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Near Limit',
                          style: AppTheme.subtitleStyle.copyWith(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...budgetProvider.nearLimitBudgets.map((budget) {
                      final category = categoryProvider.getCategoryById(budget.categoryId);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${category?.name ?? 'Unknown'}: ${budget.percentageUsed.toStringAsFixed(0)}% used',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.warning,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Budgets List
            Text(
              'Active Budgets',
              style: AppTheme.titleStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            ...activeBudgets.map((budget) {
              final category = categoryProvider.getCategoryById(budget.categoryId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BudgetCard(
                  budget: budget,
                  category: category,
                  onTap: () => _editBudget(budget),
                  onDelete: () => _deleteBudget(budget),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.titleStyle.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.captionStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetAnalysis(
    BudgetProvider budgetProvider, 
    CategoryProvider categoryProvider, 
    ExpenseProvider expenseProvider,
  ) {
    // Calculate categories without budgets
    final expenseCategories = categoryProvider.expenseCategories;
    final categoriesWithoutBudgets = expenseCategories.where((category) {
      return !budgetProvider.budgets.any((budget) => budget.categoryId == category.id);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget Performance Summary
          Text(
            'Budget Performance',
            style: AppTheme.titleStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Overall Progress
                Row(
                  children: [
                    Icon(
                      Icons.pie_chart,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overall Budget Usage',
                            style: AppTheme.subtitleStyle.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${budgetProvider.totalBudgetAmount > 0 
                                ? ((budgetProvider.totalSpentAmount / budgetProvider.totalBudgetAmount) * 100).toStringAsFixed(1)
                                : 0.0}% of total budget',
                            style: AppTheme.bodyStyle.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${AppConstants.currencySymbol}${NumberFormat('#,##,##0', 'en_IN').format(budgetProvider.totalSpentAmount)}',
                      style: AppTheme.titleStyle.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progress Bar
                LinearProgressIndicator(
                  value: budgetProvider.totalBudgetAmount > 0 
                      ? budgetProvider.totalSpentAmount / budgetProvider.totalBudgetAmount
                      : 0.0,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    budgetProvider.totalSpentAmount > budgetProvider.totalBudgetAmount
                        ? AppTheme.lightError
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Categories Without Budgets
          Text(
            'Categories Without Budgets',
            style: AppTheme.titleStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          ...[
            if (categoriesWithoutBudgets.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.success,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All expense categories have budgets set up!',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...categoriesWithoutBudgets.map((category) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getCategoryIcon(category.name),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category.name,
                          style: AppTheme.bodyStyle.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _addBudgetForCategory(category),
                        child: const Text('Set Budget'),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }

  void _addBudget() {
    showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(
        onBudgetAdded: (budget) async {
          try {
            final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
            await budgetProvider.addBudget(budget);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Budget created successfully'),
                  backgroundColor: AppTheme.success,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error creating budget: $e'),
                  backgroundColor: AppTheme.lightError,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _addBudgetForCategory(models.Category category) {
    showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(
        preselectedCategoryId: category.id,
        onBudgetAdded: (budget) async {
          try {
            final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
            await budgetProvider.addBudget(budget);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Budget created successfully'),
                  backgroundColor: AppTheme.success,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error creating budget: $e'),
                  backgroundColor: AppTheme.lightError,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _editBudget(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(
        budget: budget,
        onBudgetAdded: (updatedBudget) async {
          try {
            final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
            await budgetProvider.updateBudget(updatedBudget);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Budget updated successfully'),
                  backgroundColor: AppTheme.success,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating budget: $e'),
                  backgroundColor: AppTheme.lightError,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteBudget(Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
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
        final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
        await budgetProvider.deleteBudget(budget.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Budget deleted successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting budget: $e'),
              backgroundColor: AppTheme.lightError,
            ),
          );
        }
      }
    }
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
    };
    return icons[categoryName] ?? '💳';
  }
}
