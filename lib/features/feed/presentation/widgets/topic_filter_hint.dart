import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

class TopicFilterHint extends StatelessWidget {
  final int count;
  final VoidCallback onEdit;

  const TopicFilterHint({super.key, required this.count, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Text('$_label · ', style: theme.textTheme.labelMedium),
                Text(
                  'Edit',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _label {
    if (count == 0) return 'Showing all topics';
    return 'Showing $count ${count == 1 ? 'topic' : 'topics'}';
  }
}
