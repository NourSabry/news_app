import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../feed/presentation/widgets/article_card.dart';

class RelatedStories extends StatelessWidget {
  final List<Article> articles;
  final ValueChanged<Article> onTap;

  const RelatedStories({super.key, required this.articles, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.screenPadding,
            child: Text('Related stories', style: Theme.of(context).textTheme.headlineSmall),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screenPadding,
              itemCount: articles.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, index) => SizedBox(
                width: 220,
                child: ArticleCard(
                  article: articles[index],
                  compact: true,
                  onTap: () => onTap(articles[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
