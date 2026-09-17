import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../features/feed/presentation/widgets/article_cards.dart';
import '../article_sync.dart';

class LiveArticleCard extends StatelessWidget {
  final Article article;
  final String topicName;
  final ArticleCardVariant variant;
  final VoidCallback? onTap;

  const LiveArticleCard({
    super.key,
    required this.article,
    this.topicName = '',
    this.variant = ArticleCardVariant.standard,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final live = context.liveArticle(article);
    return EditionArticleCard(
      article: live,
      topicName: topicName,
      variant: variant,
      onTap: onTap,
      onLike: () => context.toggleLike(live),
      onBookmark: () => context.toggleBookmark(live),
    );
  }
}
