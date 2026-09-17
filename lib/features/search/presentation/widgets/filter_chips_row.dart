import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/edition_pill.dart';
import '../../domain/search_filters.dart';

/// Applied filters as removable ink-outlined pills (Part 6.7). Only
/// `topicId` is wired before the filter sheet ships (G1).
class FilterChipsRow extends StatelessWidget {
  final SearchFilters filters;
  final String topicName;
  final VoidCallback onRemoveTopic;

  const FilterChipsRow({
    super.key,
    required this.filters,
    required this.topicName,
    required this.onRemoveTopic,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty || topicName.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.sm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: EditionPill(label: topicName, onRemove: onRemoveTopic),
      ),
    );
  }
}
