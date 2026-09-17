import 'package:flutter/material.dart';
import '../../../../app/widgets/live_article_card.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/pagination_footer.dart';
import '../../../feed/presentation/widgets/article_cards.dart';
import '../bloc/search_bloc.dart';

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
      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
      itemCount: results.length + 2,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (_, index) {
        if (index == 0) return _ResultsCaption(state: state);
        if (index == results.length + 1) {
          return PaginationFooter(isLoadingMore: state.isLoadingMore, hasMore: state.hasMore);
        }
        final article = results[index - 1];
        return LiveArticleCard(
          key: ValueKey(article.id),
          article: article,
          topicName: state.topicNameFor(article.topicId),
          variant: ArticleCardVariant.standard,
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
    final brightness = Theme.of(context).brightness;
    final inkMuted = brightness == Brightness.light ? AppColors.lightInkMuted : AppColors.darkInkMuted;
    final topic = state.filters.topicId == null ? null : state.topicNameFor(state.filters.topicId!);
    final count = state.results.length;
    final scope = topic == null ? '' : ' in $topic';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        '$count ${count == 1 ? 'result' : 'results'} for "${state.query}"$scope',
        style: AppTextStyles.caption.copyWith(color: inkMuted),
      ),
    );
  }
}
