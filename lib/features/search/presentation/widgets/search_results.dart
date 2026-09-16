import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pagination_footer.dart';
import '../../../feed/presentation/widgets/article_card.dart';
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      itemCount: results.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (_, index) {
        if (index == results.length) {
          return PaginationFooter(isLoadingMore: state.isLoadingMore, hasMore: state.hasMore);
        }
        final article = results[index];
        return ArticleCard(
          key: ValueKey(article.id),
          article: article,
          topicName: state.topicNameFor(article.topicId),
          onTap: () => onTap(article),
        );
      },
    );
  }
}
