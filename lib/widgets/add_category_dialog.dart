import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/category.dart' as models;

class AddCategoryDialog extends StatefulWidget {
  final models.Category? category; // For editing existing category
  final bool isIncome;
  final Function(models.Category) onCategoryAdded;

  const AddCategoryDialog({
    super.key,
    this.category,
    required this.isIncome,
    required this.onCategoryAdded,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetLimitController = TextEditingController();

  String _selectedColor = '#6366F1';
  String _selectedIcon = '📦';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.category != null) {
      // Edit mode - populate fields with existing data
      final category = widget.category!;
      _nameController.text = category.name;
      _descriptionController.text = category.description;
      _budgetLimitController.text = category.budgetLimit > 0 
          ? category.budgetLimit.toString() 
          : '';
      _selectedColor = category.color;
      _selectedIcon = category.icon;
    } else {
      // Add mode - set default values
      _selectedColor = _getDefaultColor();
      _selectedIcon = _getDefaultIcon();
    }
  }

  String _getDefaultColor() {
    final colors = [
      '#6366F1', '#8B5CF6', '#EC4899', '#F43F5E',
      '#F97316', '#EAB308', '#84CC16', '#22C55E',
      '#14B8A6', '#06B6D4', '#3B82F6', '#6366F1'
    ];
    return colors[(DateTime.now().millisecondsSinceEpoch) % colors.length];
  }

  String _getDefaultIcon() {
    final icons = widget.isIncome 
        ? ['💰', '💵', '💳', '🏦', '📈', '💎', '🏪', '💼']
        : ['🛒', '🍕', '🚗', '🏠', '📱', '🎮', '🎬', '📚'];
    return icons[(DateTime.now().millisecondsSinceEpoch) % icons.length];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetLimitController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final category = models.Category(
      id: widget.category?.id,
      name: _nameController.text.trim(),
      color: _selectedColor,
      icon: _selectedIcon,
      description: _descriptionController.text.trim(),
      budgetLimit: _budgetLimitController.text.trim().isEmpty 
          ? 0.0 
          : double.tryParse(_budgetLimitController.text.trim()) ?? 0.0,
    );

    widget.onCategoryAdded(category);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'Enter category name',
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter category description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                
                const SizedBox(height: 16),
                
                // Budget Limit Field
                TextFormField(
                  controller: _budgetLimitController,
                  decoration: InputDecoration(
                    labelText: 'Budget Limit (Optional)',
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final amount = double.tryParse(value);
                      if (amount == null || amount < 0) {
                        return 'Please enter a valid amount';
                      }
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Color Selection
                Text(
                  'Color',
                  style: AppTheme.subtitleStyle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _buildColorSelector(),
                
                const SizedBox(height: 24),
                
                // Icon Selection
                Text(
                  'Icon',
                  style: AppTheme.subtitleStyle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _buildIconSelector(),
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
          onPressed: _saveCategory,
          child: Text(widget.category == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    final colors = [
      '#6366F1', '#8B5CF6', '#EC4899', '#F43F5E',
      '#F97316', '#EAB308', '#84CC16', '#22C55E',
      '#14B8A6', '#06B6D4', '#3B82F6', '#6366F1'
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = color == _selectedColor;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(int.parse(color.replaceAll('#', '0xFF'))),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconSelector() {
    final icons = widget.isIncome 
        ? ['💰', '💵', '💳', '🏦', '📈', '💎', '🏪', '💼', '🎯', '🏆', '🎁', '⭐']
        : ['🛒', '🍕', '🚗', '🏠', '📱', '🎮', '🎬', '📚', '🏃', '🎨', '🎵', '⚽'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: icons.map((icon) {
        final isSelected = icon == _selectedIcon;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = icon),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
