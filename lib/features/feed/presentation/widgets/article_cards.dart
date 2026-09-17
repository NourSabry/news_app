import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/hairline.dart';
import '../../../reactions/presentation/widgets/engagement_row.dart';

enum ArticleCardVariant { lead, standard, brief }

/// The three feed card variants (Part 6.6). Brief is also used in place
/// of Standard when there's no image, or at text scale ≥ 1.5.
class EditionArticleCard extends StatelessWidget {
  final Article article;
  final String topicName;
  final ArticleCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;

  const EditionArticleCard({
    super.key,
    required this.article,
    required this.variant,
    this.topicName = '',
    this.onTap,
    this.onLike,
    this.onBookmark,
  });

  ArticleCardVariant get _effectiveVariant =>
      variant == ArticleCardVariant.standard && (article.image == null || article.image!.isEmpty)
          ? ArticleCardVariant.brief
          : variant;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScale = mediaQuery.textScaler.scale(14) / 14;
    final effective =
        textScale >= 1.5 && _effectiveVariant != ArticleCardVariant.lead
            ? ArticleCardVariant.brief
            : _effectiveVariant;

    final label =
        '${article.title}. $topicName, ${TimeFormatter.relative(article.publishedAt)}. '
        '${article.likes} likes, ${article.comments} comments${article.isBookmarked ? ', saved' : ''}';

    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: switch (effective) {
          ArticleCardVariant.lead => _LeadLayout(article: article, topicName: topicName, onLike: onLike, onBookmark: onBookmark),
          ArticleCardVariant.standard => _StandardLayout(article: article, topicName: topicName, onLike: onLike, onBookmark: onBookmark),
          ArticleCardVariant.brief => _BriefLayout(article: article, topicName: topicName, onLike: onLike, onBookmark: onBookmark),
        },
      ),
    );
  }
}

class _SectionTag extends StatelessWidget {
  final String topicName;

  const _SectionTag({required this.topicName});

  @override
  Widget build(BuildContext context) {
    if (topicName.isEmpty) return const SizedBox.shrink();
    final brightness = Theme.of(context).brightness;
    final tint = AppColors.sectionTint(topicName, brightness);
    return Text(topicName.toUpperCase(), style: AppTextStyles.overline.copyWith(color: tint));
  }
}

class _Byline extends StatelessWidget {
  final Article article;
  final Color color;

  const _Byline({required this.article, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${article.source} · ${article.author.name} · ${TimeFormatter.relative(article.publishedAt)}',
      style: AppTextStyles.caption.copyWith(color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _LeadLayout extends StatelessWidget {
  final Article article;
  final String topicName;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;

  const _LeadLayout({required this.article, required this.topicName, this.onLike, this.onBookmark});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final paper = isLight ? AppColors.lightPaper : AppColors.darkPaper;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final overlayBase = isLight ? paper : ink;
    final onOverlay = isLight ? ink : paper;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusImage),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: CachedImage(imageUrl: article.image, borderRadius: 0),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.45, 1],
                      colors: [
                        overlayBase.withValues(alpha: 0.5),
                        overlayBase.withValues(alpha: 0.72),
                        overlayBase.withValues(alpha: 0.94),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SectionTag(topicName: topicName),
                      const SizedBox(height: AppSpacing.xs),
                      Text(article.title, style: AppTextStyles.displayL.copyWith(color: onOverlay), maxLines: 3, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: AppSpacing.xs),
                      _Byline(article: article, color: onOverlay.withValues(alpha: 0.8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        EngagementRow(article: article, onLike: onLike, onBookmark: onBookmark),
      ],
    );
  }
}

class _StandardLayout extends StatelessWidget {
  final Article article;
  final String topicName;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;

  const _StandardLayout({required this.article, required this.topicName, this.onLike, this.onBookmark});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTag(topicName: topicName),
                  const SizedBox(height: AppSpacing.xs),
                  Text(article.title, style: AppTextStyles.headlineM.copyWith(color: ink), maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.xs),
                  Text(article.summary, style: AppTextStyles.bodyS.copyWith(color: inkMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.sm),
                  _Byline(article: article, color: inkMuted),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusImage),
              child: CachedImage(imageUrl: article.image, width: 96, height: 96, borderRadius: 0),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        EngagementRow(article: article, onLike: onLike, onBookmark: onBookmark),
        const SizedBox(height: AppSpacing.md),
        const Hairline(),
      ],
    );
  }
}

class _BriefLayout extends StatelessWidget {
  final Article article;
  final String topicName;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;

  const _BriefLayout({required this.article, required this.topicName, this.onLike, this.onBookmark});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTag(topicName: topicName),
        const SizedBox(height: AppSpacing.xs),
        Text(article.title, style: AppTextStyles.headlineS.copyWith(color: ink), maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: AppSpacing.xs),
        _Byline(article: article, color: inkMuted),
        const SizedBox(height: AppSpacing.sm),
        EngagementRow(article: article, onLike: onLike, onBookmark: onBookmark),
        const SizedBox(height: AppSpacing.sm),
        const Hairline(),
      ],
    );
  }
}
