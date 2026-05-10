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
import 'analytics_screen.dart';

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
      const AnalyticsScreen(),
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
                  gradient: LinearGradient(
                  colors: AppTheme.primaryGradient,
                ),
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
          ),
        );
      },
    );
  }

  Widget _buildBudgetProgress() {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        final activeBudgets = budgetProvider.activeBudgets;
        
        if (activeBudgets.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget Progress',
                style: AppTheme.titleStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              BudgetProgressList(budgets: activeBudgets),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactions() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final recentExpenses = expenseProvider.expenses;
        
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (recentExpenses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
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
                        style: AppTheme.subtitleStyle.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start tracking your expenses by adding your first transaction',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
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
    );
  }

  Widget _buildSettingsScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: AppTheme.titleStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            
            // App Info
            Card(
              child: ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                subtitle: Text('Expense Tracker PWA v${AppConstants.appVersion}'),
                onTap: () {
                  // TODO: Show about dialog
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Theme Settings
            Card(
              child: ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                subtitle: const Text('Customize app appearance'),
                onTap: () {
                  // TODO: Show theme selector
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Currency Settings
            Card(
              child: ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Currency'),
                subtitle: Text(AppConstants.defaultCurrency),
                onTap: () {
                  // TODO: Show currency selector
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Data Management
            Card(
              child: ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup & Restore'),
                subtitle: const Text('Manage your data'),
                onTap: () {
                  // TODO: Navigate to backup screen
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Security
            Card(
              child: ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Security'),
                subtitle: const Text('PIN lock and privacy settings'),
                onTap: () {
                  // TODO: Navigate to security screen
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Help & Support
            Card(
              child: ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                subtitle: const Text('Get help and contact support'),
                onTap: () {
                  // TODO: Navigate to help screen
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
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
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance),
          label: 'Budgets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
