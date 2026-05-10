import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/budget.dart';
import '../models/category.dart' as models;
import '../providers/category_provider.dart';

class AddBudgetDialog extends StatefulWidget {
  final Budget? budget; // For editing existing budget
  final String? preselectedCategoryId; // For pre-selecting a category
  final Function(Budget) onBudgetAdded;

  const AddBudgetDialog({
    super.key,
    this.budget,
    this.preselectedCategoryId,
    required this.onBudgetAdded,
  });

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String? _selectedCategoryId;
  String _selectedPeriod = AppConstants.budgetPeriods.first;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.budget != null) {
      // Edit mode - populate fields with existing data
      final budget = widget.budget!;
      _amountController.text = budget.amount.toString();
      _selectedCategoryId = budget.categoryId;
      _selectedPeriod = budget.period;
      _startDate = budget.startDate;
      _endDate = budget.endDate;
      
      if (_startDate != null) {
        _startDateController.text = DateFormat('MMM dd, yyyy').format(_startDate!);
      }
      if (_endDate != null) {
        _endDateController.text = DateFormat('MMM dd, yyyy').format(_endDate!);
      }
    } else {
      // Add mode - set default values
      _selectedCategoryId = widget.preselectedCategoryId;
      _startDate = DateTime.now();
      _endDate = _calculateEndDate(DateTime.now(), _selectedPeriod);
      
      _startDateController.text = DateFormat('MMM dd, yyyy').format(_startDate!);
      _endDateController.text = DateFormat('MMM dd, yyyy').format(_endDate!);
    }
  }

  DateTime? _calculateEndDate(DateTime startDate, String period) {
    switch (period) {
      case 'weekly':
        return startDate.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(startDate.year, startDate.month + 1, startDate.day - 1);
      case 'quarterly':
        return DateTime(startDate.year, startDate.month + 3, startDate.day - 1);
      case 'yearly':
        return DateTime(startDate.year + 1, startDate.month, startDate.day - 1);
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppTheme.lightError,
        ),
      );
      return;
    }

    final budget = Budget(
      id: widget.budget?.id,
      categoryId: _selectedCategoryId!,
      amount: double.parse(_amountController.text.trim()),
      spent: widget.budget?.spent ?? 0.0,
      period: _selectedPeriod,
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      isActive: true,
    );

    widget.onBudgetAdded(budget);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final expenseCategories = categoryProvider.expenseCategories;
        
        return AlertDialog(
          title: Text(widget.budget == null ? 'Create Budget' : 'Edit Budget'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Selection
                    Text(
                      'Category',
                      style: AppTheme.subtitleStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        hintText: 'Select category',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: expenseCategories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Row(
                            children: [
                              Text(
                                _getCategoryIcon(category.name),
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Budget Amount
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Budget Amount',
                        hintText: '0.00',
                        prefixIcon: const Icon(Icons.attach_money),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a budget amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Budget Period
                    Text(
                      'Budget Period',
                      style: AppTheme.subtitleStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPeriod,
                      decoration: const InputDecoration(
                        hintText: 'Select period',
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      items: AppConstants.budgetPeriods.map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(period.capitalize()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPeriod = value;
                            _endDate = _calculateEndDate(_startDate ?? DateTime.now(), value);
                            if (_endDate != null) {
                              _endDateController.text = DateFormat('MMM dd, yyyy').format(_endDate!);
                            }
                          });
                        }
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Date Range
                    Text(
                      'Date Range',
                      style: AppTheme.subtitleStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        // Start Date
                        Expanded(
                          child: TextFormField(
                            controller: _startDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              hintText: 'Select start date',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: _selectStartDate,
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // End Date
                        Expanded(
                          child: TextFormField(
                            controller: _endDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                              hintText: 'Select end date',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: _selectEndDate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _saveBudget,
              child: Text(widget.budget == null ? 'Create' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        _startDateController.text = DateFormat('MMM dd, yyyy').format(date);
        _endDate = _calculateEndDate(date, _selectedPeriod);
        if (_endDate != null) {
          _endDateController.text = DateFormat('MMM dd, yyyy').format(_endDate!);
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
        _endDateController.text = DateFormat('MMM dd, yyyy').format(date);
      });
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
