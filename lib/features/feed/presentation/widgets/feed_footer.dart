import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

class FeedFooter extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasMore;

  const FeedFooter({super.key, required this.isLoadingMore, required this.hasMore});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Center(
        child: isLoadingMore
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : hasMore
                ? const SizedBox.shrink()
                : Text("You're all caught up", style: theme.textTheme.labelMedium),
      ),
    );
  }
}
