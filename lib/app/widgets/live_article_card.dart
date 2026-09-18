import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../features/feed/presentation/widgets/article_cards.dart';
import '../article_sync.dart';

class LiveArticleCard extends StatelessWidget {
  final Article article;
  final String topicName;
  final ArticleCardVariant variant;
  final VoidCallback? onTap;
  final bool showSectionTag;

  const LiveArticleCard({
    super.key,
    required this.article,
    this.topicName = '',
    this.variant = ArticleCardVariant.standard,
    this.onTap,
    this.showSectionTag = true,
  });

  @override
  Widget build(BuildContext context) {
    final live = context.liveArticle(article);
    final isLikeInFlight = context.isLikeInFlight(article.id);
    return EditionArticleCard(
      article: live,
      topicName: topicName,
      variant: variant,
      showSectionTag: showSectionTag,
      onTap: onTap,
      onLike: isLikeInFlight ? null : () => context.toggleLike(live),
      onBookmark: () => context.toggleBookmark(live),
    );
  }
}
