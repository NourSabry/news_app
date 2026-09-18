import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/edition_pill.dart';
import '../../../../core/widgets/ink_button.dart';
import '../../domain/search_filters.dart';
import '../bloc/search_bloc.dart';

const _datePresetLabels = {
  DateRangePreset.today: 'Today',
  DateRangePreset.past7Days: 'Past 7 days',
  DateRangePreset.past30Days: 'Past 30 days',
  DateRangePreset.custom: 'Custom',
};

/// The filter sheet: Topic, Source (scoped to the chosen topic) and Date,
/// each a wrap of pills. Applied on dismiss with the Apply button.
class FilterSheet extends StatefulWidget {
  final SearchFilters initial;
  final List<Topic> topics;

  const FilterSheet({super.key, required this.initial, required this.topics});

  static Future<SearchFilters?> show(
    BuildContext context, {
    required SearchFilters initial,
    required List<Topic> topics,
  }) {
    final bloc = context.read<SearchBloc>();
    return showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: bloc,
        child: FilterSheet(initial: initial, topics: topics),
      ),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late SearchFilters _draft = widget.initial;

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(SourcesRequested(_draft.topicId));
  }

  void _setTopic(String? topicId) {
    setState(() => _draft = _draft.copyWith(topicId: topicId, source: null));
    context.read<SearchBloc>().add(SourcesRequested(topicId));
  }

  void _setSource(String? source) =>
      setState(() => _draft = _draft.copyWith(source: source));

  void _setDate(DateRange? date) =>
      setState(() => _draft = _draft.copyWith(date: date));

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _draft.date?.preset == DateRangePreset.custom
          ? DateTimeRange(start: _draft.date!.from, end: _draft.date!.to)
          : null,
    );
    if (picked != null) {
      _setDate(DateRange.custom(from: picked.start, to: picked.end));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final sources = context.select<SearchBloc, List<String>>(
      (bloc) => bloc.state.sources,
    );

    return Container(
      decoration: BoxDecoration(
        color: p.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: p.surfaceHigh,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.lg,
                AppSpacing.gutter,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filters',
                      style: AppTextStyles.headlineM.copyWith(color: p.ink),
                    ),
                  ),
                  Semantics(
                    button: true,
                    container: true,
                    excludeSemantics: true,
                    label: 'Clear all filters',
                    child: InkWell(
                      onTap: () => setState(() => _draft = SearchFilters.none),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Text(
                          'Clear all',
                          style: AppTextStyles.label.copyWith(
                            color: p.inkMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('TOPIC'),
                    _Choices(
                      children: [
                        _choice(
                          'All topics',
                          _draft.topicId == null,
                          () => _setTopic(null),
                        ),
                        for (final topic in widget.topics)
                          _choice(
                            topic.name,
                            _draft.topicId == topic.id,
                            () => _setTopic(topic.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel('SOURCE'),
                    _Choices(
                      children: [
                        _choice(
                          'All sources',
                          _draft.source == null,
                          () => _setSource(null),
                        ),
                        for (final source in sources)
                          _choice(
                            source,
                            _draft.source == source,
                            () => _setSource(source),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionLabel('DATE'),
                    _Choices(
                      children: [
                        _choice(
                          'Any time',
                          _draft.date == null,
                          () => _setDate(null),
                        ),
                        _choice(
                          _datePresetLabels[DateRangePreset.today]!,
                          _draft.date?.preset == DateRangePreset.today,
                          () => _setDate(DateRange.today()),
                        ),
                        _choice(
                          _datePresetLabels[DateRangePreset.past7Days]!,
                          _draft.date?.preset == DateRangePreset.past7Days,
                          () => _setDate(DateRange.past7Days()),
                        ),
                        _choice(
                          _datePresetLabels[DateRangePreset.past30Days]!,
                          _draft.date?.preset == DateRangePreset.past30Days,
                          () => _setDate(DateRange.past30Days()),
                        ),
                        _choice(
                          _datePresetLabels[DateRangePreset.custom]!,
                          _draft.date?.preset == DateRangePreset.custom,
                          _pickCustomRange,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.md,
                AppSpacing.gutter,
                AppSpacing.lg,
              ),
              child: InkButton(
                label: 'Show results',
                onPressed: () => Navigator.of(context).pop(_draft),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _choice(String label, bool selected, VoidCallback onTap) {
    return EditionPill(
      label: label,
      variant: selected ? EditionPillVariant.filled : EditionPillVariant.tonal,
      onTap: onTap,
    );
  }
}

class _Choices extends StatelessWidget {
  final List<Widget> children;

  const _Choices({required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: children,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        text,
        style: AppTextStyles.overline.copyWith(color: context.palette.inkMuted),
      ),
    );
  }
}
