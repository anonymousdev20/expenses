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
import '../services/pdf_import_service.dart';
import 'package:file_picker/file_picker.dart';

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
      backgroundColor: AppTheme.lightBackground,
      body: Column(
        children: [
          // Gradient header
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
                child: Row(
                  children: [
                    _isSearching
                        ? Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search transactions...',
                                hintStyle: const TextStyle(color: Colors.white60),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                Provider.of<ExpenseProvider>(context, listen: false)
                                    .setSearchQuery(value);
                              },
                            ),
                          )
                        : Expanded(
                            child: Text('Transactions',
                                style: AppTheme.titleStyle.copyWith(
                                    color: Colors.white, fontSize: 20)),
                          ),
                    IconButton(
                      icon: Icon(
                        _isSearching ? Icons.close : Icons.search,
                        color: Colors.white,
                      ),
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
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: _showFilterDialog,
                    ),
                    IconButton(
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      tooltip: 'Import PDF',
                      onPressed: _importPdf,
                    ),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                      tooltip: 'Export PDF',
                      onPressed: _exportPdf,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Body
          Expanded(
            child: Consumer<ExpenseProvider>(
              builder: (context, expenseProvider, child) {
                if (expenseProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (expenseProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 16),
                        Text('Error loading transactions',
                            style: AppTheme.titleStyle.copyWith(
                                color: Theme.of(context).colorScheme.error)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _loadTransactions,
                            child: const Text('Retry')),
                      ],
                    ),
                  );
                }
                final transactions = expenseProvider.expenses;
                if (transactions.isEmpty) return _buildEmptyState();
                return Column(
                  children: [
                    _buildFilterChips(expenseProvider),
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
                              onTap: () => _viewExpense(expense),
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
          ),
        ],
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

  Future<void> _importPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    List<ParsedTransaction> parsed;
    try {
      parsed = await PdfImportService.parsePdf(result.files.single.bytes!);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse PDF: $e'), backgroundColor: AppTheme.lightError),
        );
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // close loading

    if (parsed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions found in this PDF.')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => _PdfImportPreviewDialog(
        transactions: parsed,
        onConfirm: (selected) async {
          final expenses = PdfImportService.toExpenses(selected);
          final provider = Provider.of<ExpenseProvider>(context, listen: false);
          for (final e in expenses) {
            await provider.addExpense(e);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${expenses.length} transactions imported successfully'),
                backgroundColor: AppTheme.success,
              ),
            );
          }
        },
      ),
    );
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

  void _viewExpense(Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TransactionDetailSheet(
        expense: expense,
        onEdit: () {
          Navigator.of(context).pop();
          _editExpense(expense);
        },
        onDelete: () {
          Navigator.of(context).pop();
          _deleteExpense(expense);
        },
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
                      AppConstants.currencySymbol +
                      NumberFormat('#,##,##0.00', 'en_IN').format(expense.amount),
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

class _TransactionDetailSheet extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionDetailSheet({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##,##0.00', 'en_IN');
    final color = expense.isIncome ? AppTheme.success : AppTheme.lightError;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Amount + type badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${expense.isIncome ? '+' : '-'}${AppConstants.currencySymbol}${fmt.format(expense.amount)}',
                      style: AppTheme.titleStyle.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      expense.isIncome ? 'Income' : 'Expense',
                      style: AppTheme.captionStyle.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                expense.title,
                style: AppTheme.titleStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // Details rows
              _detailRow(context, Icons.category, 'Category', expense.category),
              _detailRow(context, Icons.calendar_today, 'Date',
                  DateFormat('dd MMM yyyy, hh:mm a').format(expense.date)),
              _detailRow(context, Icons.payment, 'Payment Method', expense.paymentMethod),
              if (expense.notes.isNotEmpty)
                _detailRow(context, Icons.note, 'Notes', expense.notes),
              if (expense.location != null && expense.location!.isNotEmpty)
                _detailRow(context, Icons.location_on, 'Location', expense.location!),
              if (expense.tags.isNotEmpty)
                _detailRow(context, Icons.tag, 'Tags', expense.tags.join(', ')),
              if (expense.isRecurring)
                _detailRow(context, Icons.repeat, 'Recurring',
                    expense.recurringPattern ?? 'Yes'),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.lightError,
                        side: BorderSide(color: AppTheme.lightError),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTheme.captionStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTheme.bodyStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
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

// ── PDF Import Preview Dialog ─────────────────────────────────────────────────

class _PdfImportPreviewDialog extends StatefulWidget {
  final List<ParsedTransaction> transactions;
  final Future<void> Function(List<ParsedTransaction> selected) onConfirm;

  const _PdfImportPreviewDialog({
    required this.transactions,
    required this.onConfirm,
  });

  @override
  State<_PdfImportPreviewDialog> createState() => _PdfImportPreviewDialogState();
}

class _PdfImportPreviewDialogState extends State<_PdfImportPreviewDialog> {
  late List<bool> _selected;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _selected = List.filled(widget.transactions.length, true);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selected.where((s) => s).length;
    final fmt = NumberFormat('#,##,##0.00', 'en_IN');

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.upload_file),
          const SizedBox(width: 8),
          Text('Import ${widget.transactions.length} Transactions'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            Row(
              children: [
                Text('$selectedCount selected',
                    style: AppTheme.captionStyle),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _selected = List.filled(widget.transactions.length, true)),
                  child: const Text('All'),
                ),
                TextButton(
                  onPressed: () => setState(() => _selected = List.filled(widget.transactions.length, false)),
                  child: const Text('None'),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: widget.transactions.length,
                itemBuilder: (context, i) {
                  final t = widget.transactions[i];
                  final color = t.isIncome ? AppTheme.success : AppTheme.lightError;
                  return CheckboxListTile(
                    value: _selected[i],
                    onChanged: (v) => setState(() => _selected[i] = v ?? false),
                    dense: true,
                    title: Text(
                      t.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy').format(t.date),
                      style: AppTheme.captionStyle,
                    ),
                    secondary: Text(
                      '${t.isIncome ? '+' : '-'}${AppConstants.currencySymbol}${fmt.format(t.amount)}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _importing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _importing || selectedCount == 0
              ? null
              : () async {
                  setState(() => _importing = true);
                  final selected = [
                    for (int i = 0; i < widget.transactions.length; i++)
                      if (_selected[i]) widget.transactions[i]
                  ];
                  await widget.onConfirm(selected);
                  if (mounted) Navigator.of(context).pop();
                },
          child: _importing
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text('Import $selectedCount'),
        ),
      ],
    );
  }
}
