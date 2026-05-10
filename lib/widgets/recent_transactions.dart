import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/expense.dart';

class RecentTransactionItem extends StatelessWidget {
  final Expense expense;

  const RecentTransactionItem({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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

class RecentTransactions extends StatelessWidget {
  final List<Expense> expenses;
  final VoidCallback? onViewAll;

  const RecentTransactions({
    super.key,
    required this.expenses,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: const Text('See All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (expenses.isEmpty)
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
          ...expenses.take(5).map((expense) {
            return RecentTransactionItem(expense: expense);
          }),
      ],
    );
  }
}
