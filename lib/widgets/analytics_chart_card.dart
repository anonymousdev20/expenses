import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class AnalyticsChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? iconColor;

  const AnalyticsChartCard({
    super.key,
    required this.title,
    required this.child,
    this.onTap,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (iconColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 16,
                        color: iconColor ?? Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    title,
                    style: AppTheme.subtitleStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
