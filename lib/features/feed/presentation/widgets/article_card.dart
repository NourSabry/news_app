import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/topic_badge.dart';
import '../../../bookmarks/presentation/widgets/bookmark_button.dart';
import '../../../reactions/presentation/widgets/engagement_row.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final String topicName;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;

  const ArticleCard({
    super.key,
    required this.article,
    this.topicName = '',
    this.compact = false,
    this.onTap,
    this.onLike,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
              child: compact ? _buildCompactContent(context) : _buildFullContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeadline(context),
        const SizedBox(height: AppSpacing.xs),
        _buildByline(context),
      ],
    );
  }

  Widget _buildFullContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeadline(context),
        const SizedBox(height: AppSpacing.xs),
        _buildSummary(context),
        const SizedBox(height: AppSpacing.md),
        _buildByline(context),
        const SizedBox(height: AppSpacing.md),
        _buildStats(),
      ],
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        CachedImage(imageUrl: article.image, height: compact ? 110 : 180, borderRadius: 0),
        if (topicName.isNotEmpty)
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: TopicBadge(label: topicName, onImage: true),
          ),
      ],
    );
  }

  Widget _buildHeadline(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      article.title,
      style: compact ? textTheme.titleMedium : textTheme.titleLarge,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Text(
      article.summary,
      style: Theme.of(context).textTheme.bodySmall,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildByline(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            compact ? article.source : '${article.source} · ${article.author.name}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          TimeFormatter.relative(article.publishedAt),
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        EngagementRow(article: article, onLike: onLike),
        const Spacer(),
        BookmarkButton(isBookmarked: article.isBookmarked, onTap: onBookmark, compact: true),
      ],
    );
  }
}
