import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/hairline.dart';
import '../../../../core/widgets/ink_button.dart';
import '../../domain/search_filters.dart';
import '../bloc/search_bloc.dart';

const _datePresetLabels = {
  DateRangePreset.today: 'Today',
  DateRangePreset.past7Days: 'Past 7 days',
  DateRangePreset.past30Days: 'Past 30 days',
  DateRangePreset.custom: 'Custom',
};

/// The filter bottom sheet (G1): Topic, Source (scoped to the chosen
/// topic) and Date sections, sheeted on `paperRaised` with a hairline top
/// border.
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

  void _setSource(String? source) => setState(() => _draft = _draft.copyWith(source: source));

  void _setDate(DateRange? date) => setState(() => _draft = _draft.copyWith(date: date));

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
    if (picked != null) _setDate(DateRange.custom(from: picked.start, to: picked.end));
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final paperRaised = isLight ? AppColors.lightPaperRaised : AppColors.darkPaperRaised;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;
    final sources = context.select<SearchBloc, List<String>>((bloc) => bloc.state.sources);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: paperRaised),
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Hairline(),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, 0),
              child: Row(
                children: [
                  Expanded(child: Text('Filters', style: AppTextStyles.headlineM.copyWith(color: ink))),
                  InkWell(
                    onTap: () => setState(() => _draft = SearchFilters.none),
                    child: Text('Clear all', style: AppTextStyles.label.copyWith(color: inkMuted)),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('TOPIC'),
                    _ChoiceRow(
                      label: 'All topics',
                      selected: _draft.topicId == null,
                      onTap: () => _setTopic(null),
                    ),
                    for (final topic in widget.topics)
                      _ChoiceRow(
                        label: topic.name,
                        selected: _draft.topicId == topic.id,
                        onTap: () => _setTopic(topic.id),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    const _SectionLabel('SOURCE'),
                    _ChoiceRow(
                      label: 'All sources',
                      selected: _draft.source == null,
                      onTap: () => _setSource(null),
                    ),
                    for (final source in sources)
                      _ChoiceRow(
                        label: source,
                        selected: _draft.source == source,
                        onTap: () => _setSource(source),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    const _SectionLabel('DATE'),
                    _ChoiceRow(
                      label: 'Any time',
                      selected: _draft.date == null,
                      onTap: () => _setDate(null),
                    ),
                    _ChoiceRow(
                      label: _datePresetLabels[DateRangePreset.today]!,
                      selected: _draft.date?.preset == DateRangePreset.today,
                      onTap: () => _setDate(DateRange.today()),
                    ),
                    _ChoiceRow(
                      label: _datePresetLabels[DateRangePreset.past7Days]!,
                      selected: _draft.date?.preset == DateRangePreset.past7Days,
                      onTap: () => _setDate(DateRange.past7Days()),
                    ),
                    _ChoiceRow(
                      label: _datePresetLabels[DateRangePreset.past30Days]!,
                      selected: _draft.date?.preset == DateRangePreset.past30Days,
                      onTap: () => _setDate(DateRange.past30Days()),
                    ),
                    _ChoiceRow(
                      label: _datePresetLabels[DateRangePreset.custom]!,
                      selected: _draft.date?.preset == DateRangePreset.custom,
                      onTap: _pickCustomRange,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.lg),
              child: InkButton(
                label: 'Apply',
                onPressed: () => Navigator.of(context).pop(_draft),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final inkMuted = brightness == Brightness.light ? AppColors.lightInkMuted : AppColors.darkInkMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(text, style: AppTextStyles.overline.copyWith(color: inkMuted)),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceRow({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final red = isLight ? AppColors.lightRed : AppColors.darkRed;

    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(child: Text(label, style: AppTextStyles.body.copyWith(color: ink))),
              if (selected) Icon(Icons.check_rounded, size: 18, color: red),
            ],
          ),
        ),
      ),
    );
  }
}
