import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';

class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMM d').format(now).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(_greetingFor(now.hour), style: theme.textTheme.headlineLarge),
        ],
      ),
    );
  }

  String _greetingFor(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
