import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_view.dart';

class RecentSearches extends StatelessWidget {
  final List<String> queries;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;

  const RecentSearches({
    super.key,
    required this.queries,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (queries.isEmpty) {
      return const EmptyView(
        message: 'Search for stories, topics and sources',
        icon: Icons.search_rounded,
      );
    }
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(child: Text('Recent searches', style: theme.textTheme.titleMedium)),
              TextButton(onPressed: onClear, child: const Text('Clear')),
            ],
          ),
        ),
        for (final query in queries)
          ListTile(
            leading: Icon(Icons.history_rounded, color: theme.colorScheme.onSurfaceVariant),
            title: Text(query, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => onTap(query),
          ),
      ],
    );
  }
}
