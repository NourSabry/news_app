import 'package:flutter/material.dart';
import '../../../../app/widgets/live_article_card.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../feed/presentation/widgets/article_cards.dart';

/// "More in {Topic}" — up to three compact cards under the article.
class RelatedStories extends StatelessWidget {
  final String topicName;
  final List<Article> articles;
  final ValueChanged<Article> onTap;

  const RelatedStories({
    super.key,
    required this.topicName,
    required this.articles,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.xxxl + AppSpacing.sm,
        AppSpacing.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topicName.isEmpty ? 'More stories' : 'More in $topicName',
            style: AppTextStyles.headlineM.copyWith(color: p.ink),
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final (index, article) in articles.take(3).indexed) ...[
            if (index > 0) const SizedBox(height: AppSpacing.xl),
            LiveArticleCard(
              key: ValueKey(article.id),
              article: article,
              topicName: topicName,
              variant: ArticleCardVariant.compact,
              onTap: () => onTap(article),
            ),
          ],
        ],
      ),
    );
  }
}
