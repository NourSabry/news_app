import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.sm),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
          ),
        ),
        child,
      ],
    );
  }
}
