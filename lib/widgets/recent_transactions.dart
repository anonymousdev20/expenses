import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/expense.dart';

class RecentTransactionItem extends StatelessWidget {
  final Expense expense;

  const RecentTransactionItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##,##0.00', 'en_IN');
    final isIncome = expense.isIncome;
    final amountColor = isIncome ? AppTheme.success : AppTheme.lightError;
    final amountPrefix = isIncome ? '+' : '-';
    final categoryColor = AppTheme.getCategoryColor(expense.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              _categoryEmoji(expense.category),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),

          // Title + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time + title
                Row(
                  children: [
                    Text(
                      DateFormat('HH:mm').format(expense.date),
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  expense.title,
                  style: AppTheme.subtitleStyle.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  expense.paymentMethod,
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '$amountPrefix ${AppConstants.currencySymbol}${fmt.format(expense.amount)}',
            style: AppTheme.subtitleStyle.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _categoryEmoji(String category) {
    const map = {
      'Food & Dining':    '🍔',
      'Transportation':   '🚗',
      'Shopping':         '🛍️',
      'Bills & Utilities':'📄',
      'Entertainment':    '🎮',
      'Health & Fitness': '🏃',
      'Education':        '📚',
      'Travel':           '✈️',
      'Personal Care':    '💄',
      'Gifts & Donations':'🎁',
      'Salary':           '💰',
      'Freelance':        '💻',
      'Investments':      '📈',
      'Business':         '🏢',
      'Other Income':     '💵',
    };
    return map[category] ?? '💳';
  }
}

// ── List wrapper (kept for backward compat) ───────────────────────────────────

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
            Text('Recent Transactions',
                style: AppTheme.titleStyle.copyWith(
                    color: AppTheme.primaryBlue, fontSize: 16)),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: Text('See All',
                    style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.primaryBlueMid,
                        fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (expenses.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 44,
                    color: AppTheme.primaryBlue.withOpacity(0.3)),
                const SizedBox(height: 12),
                Text('No transactions yet',
                    style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textSecondary)),
              ],
            ),
          )
        else
          ...expenses.take(5).map((e) => RecentTransactionItem(expense: e)),
      ],
    );
  }
}
