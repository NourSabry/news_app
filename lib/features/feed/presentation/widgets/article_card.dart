import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/widgets/cached_image.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final String topicName;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.article,
    this.topicName = '',
    this.onTap,
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
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeadline(context),
                  const SizedBox(height: AppSpacing.xs),
                  _buildSummary(context),
                  const SizedBox(height: AppSpacing.md),
                  _buildByline(context),
                  const SizedBox(height: AppSpacing.md),
                  _buildStats(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        CachedImage(imageUrl: article.image, height: 180, borderRadius: 0),
        if (topicName.isNotEmpty)
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: _TopicBadge(label: topicName),
          ),
      ],
    );
  }

  Widget _buildHeadline(BuildContext context) {
    return Text(
      article.title,
      style: Theme.of(context).textTheme.titleLarge,
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
            '${article.source} · ${article.author.name}',
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

  Widget _buildStats(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurfaceVariant;
    return Row(
      children: [
        _StatItem(
          icon: article.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: article.isLiked ? AppColors.liked : mutedColor,
          count: article.likes,
        ),
        const SizedBox(width: AppSpacing.lg),
        _StatItem(
          icon: Icons.chat_bubble_outline_rounded,
          color: mutedColor,
          count: article.comments,
        ),
        const Spacer(),
        if (article.isBookmarked)
          Icon(Icons.bookmark_rounded, size: 18, color: theme.colorScheme.primary),
      ],
    );
  }
}

class _TopicBadge extends StatelessWidget {
  final String label;

  const _TopicBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;

  const _StatItem({required this.icon, required this.color, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          NumberFormat.compact().format(count),
          style: theme.textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
