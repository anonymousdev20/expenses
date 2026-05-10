import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/budget.dart';

class BudgetProgress extends StatelessWidget {
  final Budget budget;

  const BudgetProgress({
    super.key,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = budget.percentageUsed;
    final isOverBudget = budget.isOverBudget;
    final isNearLimit = budget.isNearLimit;

    Color progressColor;
    if (isOverBudget) {
      progressColor = AppTheme.lightError;
    } else if (isNearLimit) {
      progressColor = AppTheme.warning;
    } else {
      progressColor = AppTheme.success;
    }

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budget.categoryId,
                style: AppTheme.subtitleStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isOverBudget)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.lightError.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Over Budget',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightError,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (isNearLimit)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Near Limit',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress Bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spent',
                    style: AppTheme.captionStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: AppTheme.captionStyle.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    NumberFormat.currency(
                      symbol: AppConstants.defaultCurrency,
                      decimalDigits: 2,
                    ).format(budget.spent),
                    style: AppTheme.captionStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'of ${NumberFormat.currency(
                      symbol: AppConstants.defaultCurrency,
                      decimalDigits: 2,
                    ).format(budget.amount)}',
                    style: AppTheme.captionStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Remaining Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining',
                style: AppTheme.captionStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                NumberFormat.currency(
                  symbol: AppConstants.defaultCurrency,
                  decimalDigits: 2,
                ).format(budget.remaining),
                style: AppTheme.captionStyle.copyWith(
                  color: budget.remaining >= 0 ? AppTheme.success : AppTheme.lightError,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BudgetProgressList extends StatelessWidget {
  final List<Budget> budgets;
  final int maxItems;

  const BudgetProgressList({
    super.key,
    required this.budgets,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.account_balance,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No budgets set',
              style: AppTheme.bodyStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create budgets to track your spending',
              style: AppTheme.captionStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...budgets.take(maxItems).map((budget) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BudgetProgress(budget: budget),
          );
        }),
        if (budgets.length > maxItems)
          TextButton(
            onPressed: () {
              // TODO: Navigate to budgets screen
            },
            child: Text('View All ${budgets.length} Budgets'),
          ),
      ],
    );
  }
}
