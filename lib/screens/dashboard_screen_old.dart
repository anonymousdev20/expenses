import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/budget_progress.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/quick_add_button.dart';
import 'transactions_screen.dart';
import 'categories_screen.dart';
import 'budgets_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildDashboardContent(),
      const TransactionsScreen(),
      const CategoriesScreen(),
      const BudgetsScreen(),
      _buildSettingsScreen(),
    ];
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Provider.of<ExpenseProvider>(context, listen: false).refresh();
      await Provider.of<CategoryProvider>(context, listen: false).refresh();
      await Provider.of<BudgetProvider>(context, listen: false).refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1 
          ? const QuickAddButton() 
          : null,
    );
  }

  Widget _buildDashboardContent() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Dashboard'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSummaryCards(),
          ),
          SliverToBoxAdapter(
            child: _buildBudgetProgress(),
          ),
          SliverToBoxAdapter(
            child: _buildRecentTransactions(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        
        final totalIncome = expenseProvider.getTotalIncome(
          startDate: startOfMonth,
          endDate: endOfMonth,
        );
        final totalExpenses = expenseProvider.getTotalExpenses(
          startDate: startOfMonth,
          endDate: endOfMonth,
        );
        final balance = totalIncome - totalExpenses;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Balance Card
              SummaryCard(
                title: 'Current Balance',
                amount: balance,
                icon: Icons.account_balance_wallet,
                color: balance >= 0 ? AppTheme.success : AppTheme.lightError,
                subtitle: DateFormat('MMM yyyy').format(now),
              ),
              
              const SizedBox(height: 16),
              
              // Income and Expenses Row
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Income',
                      amount: totalIncome,
                      icon: Icons.arrow_downward,
                      color: AppTheme.success,
                      subtitle: 'This month',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SummaryCard(
                      title: 'Expenses',
                      amount: totalExpenses,
                      icon: Icons.arrow_upward,
                      color: AppTheme.lightError,
                      subtitle: 'This month',
                    ),
                  ),
                ],
              ),
            ],

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Progress',
                          style: AppTheme.titleStyle.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...activeBudgets.take(3).map((budget) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: BudgetProgress(budget: budget),
                          );
                        }),
                        if (activeBudgets.length > 3)
                          TextButton(
                            onPressed: () {
                              // TODO: Navigate to budgets screen
                            },
                            child: const Text('View All Budgets'),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Recent Transactions
            SliverToBoxAdapter(
              child: Consumer<ExpenseProvider>(
                builder: (context, expenseProvider, child) {
                  final recentExpenses = expenseProvider.getRecentExpenses();
                  
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Transactions',
                              style: AppTheme.titleStyle.copyWith(
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Navigate to transactions screen
                              },
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (recentExpenses.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions yet',
                                  style: AppTheme.bodyStyle.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start by adding your first expense',
                                  style: AppTheme.captionStyle.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...recentExpenses.take(5).map((expense) {
                            return RecentTransactionItem(expense: expense);
                          }),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      
      // Floating Action Button
      floatingActionButton: const QuickAddButton(),
      
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // TODO: Navigate to different screens
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
