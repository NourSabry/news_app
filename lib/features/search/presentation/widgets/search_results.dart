import 'package:flutter/material.dart';
import '../../../../app/widgets/live_article_card.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/pagination_footer.dart';
import '../../../feed/presentation/widgets/article_cards.dart';
import '../../domain/search_filters.dart';
import '../bloc/search_bloc.dart';

const _datePresetCaptionLabels = {
  DateRangePreset.today: 'today',
  DateRangePreset.past7Days: 'past 7 days',
  DateRangePreset.past30Days: 'past 30 days',
  DateRangePreset.custom: 'custom range',
};

class SearchResults extends StatelessWidget {
  final SearchState state;
  final ScrollController controller;
  final ValueChanged<Article> onTap;

  const SearchResults({
    super.key,
    required this.state,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final results = state.results;
    return ListView.separated(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.dockClearance,
      ),
      itemCount: results.length + 2,
      separatorBuilder: (_, index) =>
          SizedBox(height: index == 0 ? AppSpacing.md : AppSpacing.xl),
      itemBuilder: (_, index) {
        if (index == 0) return _ResultsCaption(state: state);
        if (index == results.length + 1) {
          return PaginationFooter(
            isLoadingMore: state.isLoadingMore,
            hasMore: state.hasMore,
          );
        }
        final article = results[index - 1];
        return LiveArticleCard(
          key: ValueKey(article.id),
          article: article,
          topicName: state.topicNameFor(article.topicId),
          variant: index == 1
              ? ArticleCardVariant.standard
              : ArticleCardVariant.compact,
          onTap: () => onTap(article),
        );
      },
    );
  }
}

class _ResultsCaption extends StatelessWidget {
  final SearchState state;

  const _ResultsCaption({required this.state});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final count = state.results.length;
    final parts = [
      for (final id in state.filters.topicIds) state.topicNameFor(id),
      if (state.filters.source != null) state.filters.source!,
      if (state.filters.date != null)
        _datePresetCaptionLabels[state.filters.date!.preset]!,
    ];
    final scope = parts.isEmpty ? '' : ' in ${parts.join(', ')}';
    final subject = state.query.isEmpty ? '' : ' for "${state.query}"';
    return Text(
      '$count ${count == 1 ? 'result' : 'results'}$subject$scope',
      style: AppTextStyles.caption.copyWith(color: p.inkMuted),
    );
  }
}
