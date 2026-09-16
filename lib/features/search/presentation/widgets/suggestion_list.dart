import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

class SuggestionList extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  const SuggestionList({super.key, required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      itemCount: suggestions.length,
      itemBuilder: (_, index) => ListTile(
        leading: Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant),
        title: Text(suggestions[index], maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Icon(Icons.north_west_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
        onTap: () => onTap(suggestions[index]),
      ),
    );
  }
}
