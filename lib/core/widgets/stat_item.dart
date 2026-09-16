import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_spacing.dart';

class StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback? onTap;
  final String? tooltip;

  const StatItem({
    super.key,
    required this.icon,
    required this.color,
    required this.count,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          NumberFormat.compact().format(count),
          style: theme.textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
    if (onTap == null) return content;
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
          child: content,
        ),
      ),
    );
  }
}
