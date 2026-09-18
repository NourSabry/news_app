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

/// The filter button plus any applied filters as removable pills, in one
/// horizontally scrolling row.
class FilterChipsRow extends StatelessWidget {
  final SearchFilters filters;
  final String topicName;
  final ValueChanged<SearchFilters> onChanged;
  final VoidCallback onOpenFilters;

  const FilterChipsRow({
    super.key,
    required this.filters,
    required this.topicName,
    required this.onChanged,
    required this.onOpenFilters,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        children: [
          EditionPill(
            label: filters.isEmpty
                ? 'Filters'
                : 'Filters · ${filters.activeCount}',
            leadingIcon: Icons.tune_rounded,
            variant: filters.isEmpty
                ? EditionPillVariant.tonal
                : EditionPillVariant.filled,
            onTap: onOpenFilters,
          ),
          if (filters.topicId != null && topicName.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            EditionPill(
              label: topicName,
              onRemove: () => onChanged(filters.copyWith(topicId: null)),
            ),
          ],
          if (filters.source != null) ...[
            const SizedBox(width: AppSpacing.sm),
            EditionPill(
              label: filters.source!,
              onRemove: () => onChanged(filters.copyWith(source: null)),
            ),
          ],
          if (filters.date != null) ...[
            const SizedBox(width: AppSpacing.sm),
            EditionPill(
              label: _datePresetChipLabels[filters.date!.preset]!,
              onRemove: () => onChanged(filters.copyWith(date: null)),
            ),
          ],
        ],
      ),
    );
  }
}
