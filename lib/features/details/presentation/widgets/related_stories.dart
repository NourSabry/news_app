import 'package:flutter/material.dart';
import '../../../../app/widgets/live_article_card.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../feed/presentation/widgets/article_cards.dart';

/// "Also in {Topic}" — three Brief cards (Part 6.9).
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
    final brightness = Theme.of(context).brightness;
    final ink = brightness == Brightness.light ? AppColors.lightInk : AppColors.darkInk;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.screenPadding,
            child: Text('Also in $topicName', style: AppTextStyles.headlineS.copyWith(color: ink)),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                for (final article in articles.take(3))
                  LiveArticleCard(
                    key: ValueKey(article.id),
                    article: article,
                    topicName: topicName,
                    variant: ArticleCardVariant.brief,
                    onTap: () => onTap(article),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
