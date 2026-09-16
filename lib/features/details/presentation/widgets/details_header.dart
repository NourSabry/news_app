import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/widgets/topic_badge.dart';

class DetailsHeader extends StatelessWidget {
  final Article article;
  final String topicName;
  final bool fromCache;

  const DetailsHeader({
    super.key,
    required this.article,
    required this.topicName,
    required this.fromCache,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topicName.isNotEmpty) ...[
            TopicBadge(label: topicName),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(article.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          _AuthorRow(article: article),
          if (fromCache) ...[
            const SizedBox(height: AppSpacing.md),
            const _Note(icon: Icons.offline_pin_rounded, label: 'Showing saved copy'),
          ],
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  final Article article;

  const _AuthorRow({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readTime = article.readTimeMinutes;
    return Row(
      children: [
        _Avatar(author: article.author),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.author.name,
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${article.source} · ${TimeFormatter.relative(article.publishedAt)}',
                style: theme.textTheme.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (readTime != null) ...[
          const SizedBox(width: AppSpacing.md),
          _Note(icon: Icons.schedule_rounded, label: '$readTime min read'),
        ],
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final Author author;

  const _Avatar({required this.author});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatar = author.avatar;
    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      foregroundImage: avatar == null ? null : CachedNetworkImageProvider(avatar),
      child: Text(
        author.name.isEmpty ? '?' : author.name[0].toUpperCase(),
        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Note({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}
