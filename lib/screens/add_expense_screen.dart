import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/category_selector.dart';
import '../widgets/payment_method_selector.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense; // For editing existing expense

  const AddExpenseScreen({
    super.key,
    this.expense,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();

  String _selectedCategory = '';
  String _selectedPaymentMethod = AppConstants.paymentMethods.first;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isIncome = false;
  bool _isRecurring = false;
  String? _recurringPattern;
  String? _receiptImagePath;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.expense != null) {
      // Edit mode - populate fields with existing data
      final expense = widget.expense!;
      _titleController.text = expense.title;
      _amountController.text = expense.amount.toString();
      _notesController.text = expense.notes;
      _locationController.text = expense.location ?? '';
      _tagsController.text = expense.tags.join(', ');
      _selectedCategory = expense.category;
      _selectedPaymentMethod = expense.paymentMethod;
      _selectedDate = expense.date;
      _selectedTime = TimeOfDay.fromDateTime(expense.date);
      _isIncome = expense.isIncome;
      _isRecurring = expense.isRecurring;
      _recurringPattern = expense.recurringPattern;
      _receiptImagePath = expense.receiptImagePath;
    } else {
      // Add mode - set default values
      _selectedCategory = _getDefaultCategory();
    }
  }

  String _getDefaultCategory() {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final categories = _isIncome ? categoryProvider.incomeCategories : categoryProvider.expenseCategories;
    return categories.isNotEmpty ? categories.first.name : '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    try {
      final amount = double.parse(_amountController.text);
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final expense = Expense(
        id: widget.expense?.id,
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        paymentMethod: _selectedPaymentMethod,
        notes: _notesController.text.trim(),
        tags: tags,
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        receiptImagePath: _receiptImagePath,
        isRecurring: _isRecurring,
        recurringPattern: _recurringPattern,
        isIncome: _isIncome,
      );

      if (widget.expense == null) {
        await expenseProvider.addExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Expense added successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } else {
        await expenseProvider.updateExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Expense updated successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving expense: $e'),
            backgroundColor: AppTheme.lightError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: widget.expense == null ? null : _deleteExpense,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Income/Expense Toggle
              _buildIncomeExpenseToggle(),
              
              const SizedBox(height: 24),
              
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter expense title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixText: '${AppConstants.defaultCurrency} ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Category Selector
              CategorySelector(
                selectedCategory: _selectedCategory,
                isIncome: _isIncome,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Payment Method Selector
              PaymentMethodSelector(
                selectedPaymentMethod: _selectedPaymentMethod,
                onPaymentMethodSelected: (method) {
                  setState(() {
                    _selectedPaymentMethod = method;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Date and Time Row
              Row(
                children: [
                  // Date Picker
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: AppTheme.bodyStyle.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Time Picker
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedTime.format(context),
                              style: AppTheme.bodyStyle.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add any additional notes',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 16),
              
              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Where did this expense occur?',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tags Field
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'Enter tags separated by commas',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Recurring Toggle
              SwitchListTile(
                title: const Text('Recurring Expense'),
                subtitle: const Text('Set up automatic recurring transactions'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                    if (!value) {
                      _recurringPattern = null;
                    }
                  });
                },
              ),
              
              if (_isRecurring) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _recurringPattern,
                  decoration: const InputDecoration(
                    labelText: 'Recurring Pattern',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: AppConstants.recurringPatterns.map((pattern) {
                    return DropdownMenuItem(
                      value: pattern,
                      child: Text(pattern.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _recurringPattern = value;
                    });
                  },
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  child: Text(widget.expense == null ? 'Add Expense' : 'Update Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isIncome = false;
                  _selectedCategory = _getDefaultCategory();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isIncome ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Expense',
                  textAlign: TextAlign.center,
                  style: AppTheme.subtitleStyle.copyWith(
                    color: !_isIncome ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isIncome = true;
                  _selectedCategory = _getDefaultCategory();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isIncome ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Income',
                  textAlign: TextAlign.center,
                  style: AppTheme.subtitleStyle.copyWith(
                    color: _isIncome ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _deleteExpense() async {
    if (widget.expense == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
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
        await expenseProvider.deleteExpense(widget.expense!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense deleted successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting expense: $e'),
              backgroundColor: AppTheme.lightError,
            ),
          );
        }
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
