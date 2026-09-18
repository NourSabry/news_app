import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/widgets/edition_pill.dart';
import '../../../reactions/presentation/widgets/engagement_row.dart';

/// Section tag, headline, standfirst, byline, engagement and tags.
class DetailsHeader extends StatelessWidget {
  final Article article;
  final String topicName;
  final bool fromCache;
  final DateTime? lastSyncedAt;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;

  const DetailsHeader({
    super.key,
    required this.article,
    required this.topicName,
    required this.fromCache,
    this.lastSyncedAt,
    this.onLike,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final updated = article.updatedAt;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.xxl,
        AppSpacing.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topicName.isNotEmpty)
            Text(
              topicName.toUpperCase(),
              style: AppTextStyles.overline.copyWith(
                color: p.sectionTint(topicName),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            article.title,
            style: AppTextStyles.displayL.copyWith(color: p.ink),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            article.summary,
            style: AppTextStyles.body.copyWith(color: p.inkMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          _BylineRow(article: article),
          if (fromCache && lastSyncedAt != null) ...[
            const SizedBox(height: AppSpacing.md),
            _Note(
              icon: Icons.offline_pin_outlined,
              text: 'Saved copy · ${TimeFormatter.relative(lastSyncedAt!)}',
              color: p.warning,
            ),
          ],
          if (updated != null && updated.isAfter(article.publishedAt)) ...[
            const SizedBox(height: AppSpacing.sm),
            _Note(
              icon: Icons.history_rounded,
              text: 'Updated ${TimeFormatter.relative(updated)}',
              color: p.inkMuted,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: EngagementRow(
              article: article,
              onLike: onLike,
              onBookmark: onBookmark,
            ),
          ),
          if (article.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final tag in article.tags)
                  EditionPill(label: '#$tag', height: 32),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Note({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.caption.copyWith(color: color)),
      ],
    );
  }
}

class _BylineRow extends StatelessWidget {
  final Article article;

  const _BylineRow({required this.article});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
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
                style: AppTextStyles.label.copyWith(color: p.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${article.source} · ${TimeFormatter.relative(article.publishedAt)}'
                '${readTime != null ? ' · $readTime min read' : ''}',
                style: AppTextStyles.caption.copyWith(color: p.inkMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final Author author;

  const _Avatar({required this.author});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final avatar = author.avatar;

    return CircleAvatar(
      radius: 18,
      backgroundColor: p.ink,
      foregroundImage: avatar == null
          ? null
          : CachedNetworkImageProvider(
              avatar,
              cacheManager: ServiceLocator.instance.get<BaseCacheManager>(),
            ),
      // A broken avatar URL falls back to the initial instead of throwing.
      onForegroundImageError: avatar == null ? null : (_, _) {},
      child: Text(
        author.name.isEmpty ? '?' : author.name[0].toUpperCase(),
        style: AppTextStyles.label.copyWith(color: p.background),
      ),
    );
  }
}
