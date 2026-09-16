import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class TopicBadge extends StatelessWidget {
  final String label;
  final bool onImage;

  const TopicBadge({super.key, required this.label, this.onImage = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: onImage
            ? theme.colorScheme.surface.withValues(alpha: 0.92)
            : theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
