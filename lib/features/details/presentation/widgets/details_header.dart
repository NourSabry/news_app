import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/widgets/edition_pill.dart';
import '../../../../core/widgets/hairline.dart';
import '../../../reactions/presentation/widgets/engagement_row.dart';

/// Section tag, headline, standfirst, byline and tags (Part 6.9).
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
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;
    final warning = isLight ? AppColors.lightWarning : AppColors.darkWarning;
    final tint = AppColors.sectionTint(topicName, brightness);
    final updated = article.updatedAt;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.xl, AppSpacing.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topicName.isNotEmpty)
            Text(topicName.toUpperCase(), style: AppTextStyles.overline.copyWith(color: tint)),
          const SizedBox(height: AppSpacing.sm),
          Text(article.title, style: AppTextStyles.displayL.copyWith(color: ink)),
          const SizedBox(height: AppSpacing.md),
          Text(article.summary, style: AppTextStyles.body.copyWith(color: inkMuted)),
          const SizedBox(height: AppSpacing.lg),
          _BylineRow(article: article),
          if (fromCache && lastSyncedAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Saved copy · ${TimeFormatter.relative(lastSyncedAt!)}',
              style: AppTextStyles.caption.copyWith(color: warning),
            ),
          ],
          if (updated != null && updated.isAfter(article.publishedAt)) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Updated ${TimeFormatter.relative(updated)}',
              style: AppTextStyles.caption.copyWith(color: inkMuted),
            ),
          ],
          if (article.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [for (final tag in article.tags) EditionPill(label: tag)],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          const Hairline(),
          const SizedBox(height: AppSpacing.sm),
          EngagementRow(article: article, onLike: onLike, onBookmark: onBookmark),
          const SizedBox(height: AppSpacing.sm),
          const Hairline(),
        ],
      ),
    );
  }
}

class _BylineRow extends StatelessWidget {
  final Article article;

  const _BylineRow({required this.article});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;
    final readTime = article.readTimeMinutes;

    return Row(
      children: [
        _Avatar(author: article.author),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(article.author.name, style: AppTextStyles.label.copyWith(color: ink), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                '${article.source} · ${TimeFormatter.relative(article.publishedAt)}'
                '${readTime != null ? ' · $readTime min read' : ''}',
                style: AppTextStyles.caption.copyWith(color: inkMuted),
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
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final paper = isLight ? AppColors.lightPaper : AppColors.darkPaper;
    final avatar = author.avatar;

    return CircleAvatar(
      radius: 14,
      backgroundColor: ink,
      foregroundImage: avatar == null ? null : CachedNetworkImageProvider(avatar),
      child: Text(
        author.name.isEmpty ? '?' : author.name[0].toUpperCase(),
        style: AppTextStyles.label.copyWith(color: paper),
      ),
    );
  }
}
