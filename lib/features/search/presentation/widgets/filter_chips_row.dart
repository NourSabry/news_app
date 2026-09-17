import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/edition_pill.dart';
import '../../domain/search_filters.dart';

const _datePresetChipLabels = {
  DateRangePreset.today: 'Today',
  DateRangePreset.past7Days: 'Past 7 days',
  DateRangePreset.past30Days: 'Past 30 days',
  DateRangePreset.custom: 'Custom range',
};

/// Applied filters as removable ink-outlined pills (Part 6.7).
class FilterChipsRow extends StatelessWidget {
  final SearchFilters filters;
  final String topicName;
  final ValueChanged<SearchFilters> onChanged;

  const FilterChipsRow({
    super.key,
    required this.filters,
    required this.topicName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          if (filters.topicId != null && topicName.isNotEmpty)
            EditionPill(
              label: topicName,
              onRemove: () => onChanged(filters.copyWith(topicId: null)),
            ),
          if (filters.source != null)
            EditionPill(
              label: filters.source!,
              onRemove: () => onChanged(filters.copyWith(source: null)),
            ),
          if (filters.date != null)
            EditionPill(
              label: _datePresetChipLabels[filters.date!.preset]!,
              onRemove: () => onChanged(filters.copyWith(date: null)),
            ),
        ],
      ),
    );
  }
}
