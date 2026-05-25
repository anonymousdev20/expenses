import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../screens/add_expense_screen.dart';
import '../widgets/transaction_filter_chip.dart';
import '../widgets/transaction_search_bar.dart';
import '../services/pdf_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    await expenseProvider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search transactions...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  Provider.of<ExpenseProvider>(context, listen: false)
                      .setSearchQuery(value);
                },
              )
            : const Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  Provider.of<ExpenseProvider>(context, listen: false)
                      .setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (expenseProvider.error != null) {
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
                    'Error loading transactions',
                    style: AppTheme.titleStyle.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    expenseProvider.error!,
                    style: AppTheme.bodyStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTransactions,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final transactions = expenseProvider.expenses;

          if (transactions.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Filter Chips
              _buildFilterChips(expenseProvider),
              
              // Transactions List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadTransactions,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final expense = transactions[index];
                      return _TransactionItem(
                        expense: expense,
                        onTap: () => _editExpense(expense),
                        onDelete: () => _deleteExpense(expense),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: AppTheme.titleStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first expense or income',
            style: AppTheme.bodyStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addExpense,
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ExpenseProvider expenseProvider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Category Filter
          if (expenseProvider.selectedCategory != null)
            TransactionFilterChip(
              label: expenseProvider.selectedCategory!,
              onDeleted: () {
                expenseProvider.setCategoryFilter(null);
              },
            ),
          
          // Date Range Filter
          if (expenseProvider.startDate != null || expenseProvider.endDate != null)
            TransactionFilterChip(
              label: _formatDateRange(expenseProvider.startDate, expenseProvider.endDate),
              onDeleted: () {
                expenseProvider.setDateRangeFilter(null, null);
              },
            ),
          
          // Income/Expense Filter
          if (expenseProvider.isIncome != null)
            TransactionFilterChip(
              label: expenseProvider.isIncome! ? 'Income' : 'Expense',
              onDeleted: () {
                expenseProvider.setIncomeFilter(null);
              },
            ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      return '${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd').format(end)}';
    } else if (start != null) {
      return 'From ${DateFormat('MMM dd').format(start)}';
    } else if (end != null) {
      return 'Until ${DateFormat('MMM dd').format(end)}';
    }
    return '';
  }

  Future<void> _exportPdf() async {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final expenses = expenseProvider.expenses;
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }
    await PdfService.exportExpenses(
      context: context,
      expenses: expenses,
      title: 'Expense Report — ${DateFormat('MMMM yyyy').format(DateTime.now())}',
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(),
    );
  }

  void _addExpense() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );
  }

  void _editExpense(Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expense),
      ),
    );
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
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
        final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
        await expenseProvider.deleteExpense(expense.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction deleted successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting transaction: $e'),
              backgroundColor: AppTheme.lightError,
            ),
          );
        }
      }
    }
  }
}

class _TransactionItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TransactionItem({
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.lightError,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.getCategoryColor(expense.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getCategoryIcon(expense.category),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: AppTheme.subtitleStyle.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            expense.category,
                            style: AppTheme.captionStyle.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: AppTheme.captionStyle.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd, yyyy').format(expense.date),
                            style: AppTheme.captionStyle.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      if (expense.notes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          expense.notes,
                          style: AppTheme.captionStyle.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (expense.isIncome ? '+' : '-') + 
                      NumberFormat.currency(
                        symbol: AppConstants.defaultCurrency,
                        decimalDigits: 2,
                      ).format(expense.amount),
                      style: AppTheme.subtitleStyle.copyWith(
                        color: expense.isIncome ? AppTheme.success : AppTheme.lightError,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expense.paymentMethod,
                      style: AppTheme.captionStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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

class _FilterDialog extends StatefulWidget {
  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  bool? _isIncome;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Transactions'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter
            Text(
              'Category',
              style: AppTheme.subtitleStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            // TODO: Add category selector
            
            const SizedBox(height: 16),
            
            // Date Range Filter
            Text(
              'Date Range',
              style: AppTheme.subtitleStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectStartDate,
                    child: Text(_startDate == null ? 'Start Date' : 
                        DateFormat('MMM dd').format(_startDate!)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectEndDate,
                    child: Text(_endDate == null ? 'End Date' : 
                        DateFormat('MMM dd').format(_endDate!)),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Income/Expense Filter
            Text(
              'Type',
              style: AppTheme.subtitleStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool?>(
                    title: const Text('All'),
                    value: null,
                    groupValue: _isIncome,
                    onChanged: (value) => setState(() => _isIncome = value),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Income'),
                    value: true,
                    groupValue: _isIncome,
                    onChanged: (value) => setState(() => _isIncome = value),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Expense'),
                    value: false,
                    groupValue: _isIncome,
                    onChanged: (value) => setState(() => _isIncome = value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedCategory = null;
              _startDate = null;
              _endDate = null;
              _isIncome = null;
            });
            final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
            expenseProvider.clearFilters();
            Navigator.of(context).pop();
          },
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _applyFilters,
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  void _applyFilters() {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    expenseProvider.setCategoryFilter(_selectedCategory);
    expenseProvider.setDateRangeFilter(_startDate, _endDate);
    expenseProvider.setIncomeFilter(_isIncome);
    Navigator.of(context).pop();
  }
}
