import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../screens/add_expense_screen.dart';

class QuickAddButton extends StatelessWidget {
  const QuickAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        _showAddOptions(context);
      },
      icon: const Icon(Icons.add),
      label: const Text('Add Expense'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Text(
              'Add Transaction',
              style: AppTheme.titleStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Options
            Row(
              children: [
                // Add Expense
                Expanded(
                  child: _AddOption(
                    icon: Icons.arrow_upward,
                    label: 'Expense',
                    color: AppTheme.lightError,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddExpenseScreen(),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Add Income
                Expanded(
                  child: _AddOption(
                    icon: Icons.arrow_downward,
                    label: 'Income',
                    color: AppTheme.success,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddExpenseScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick Actions
            Row(
              children: [
                // Scan Receipt
                Expanded(
                  child: _AddOption(
                    icon: Icons.camera_alt,
                    label: 'Scan Receipt',
                    color: AppTheme.info,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement receipt scanning
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Voice Input
                Expanded(
                  child: _AddOption(
                    icon: Icons.mic,
                    label: 'Voice Input',
                    color: AppTheme.warning,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement voice input
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AddOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AddOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTheme.subtitleStyle.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
