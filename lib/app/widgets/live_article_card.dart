import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../features/feed/presentation/widgets/article_card.dart';
import '../article_sync.dart';

class LiveArticleCard extends StatelessWidget {
  final Article article;
  final String topicName;
  final bool compact;
  final VoidCallback? onTap;

  const LiveArticleCard({
    super.key,
    required this.article,
    this.topicName = '',
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final live = context.liveArticle(article);
    return ArticleCard(
      article: live,
      topicName: topicName,
      compact: compact,
      onTap: onTap,
      onLike: () => context.toggleLike(live),
      onBookmark: () => context.toggleBookmark(live),
    );
  }
}
