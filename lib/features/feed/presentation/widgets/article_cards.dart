import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../reactions/presentation/widgets/engagement_row.dart';

enum ArticleCardVariant { lead, standard, compact }

/// The three feed card layouts. Lead is a tall photo with the headline set
/// on it; standard is a wide image above text; compact is text beside a
/// thumbnail. Standard falls back to compact without an image, and to a
/// stacked compact at large text sizes.
class EditionArticleCard extends StatelessWidget {
  final Article article;
  final String topicName;
  final ArticleCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;

  /// Hide the section tag when the surrounding list already groups by it.
  final bool showSectionTag;

  const EditionArticleCard({
    super.key,
    required this.article,
    required this.variant,
    this.topicName = '',
    this.onTap,
    this.onLike,
    this.onBookmark,
    this.showSectionTag = true,
  });

  bool get _hasImage => article.image != null && article.image!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    // Without a photo, lead falls back to standard and everything else to
    // compact.
    final effective = !_hasImage
        ? (variant == ArticleCardVariant.lead ? ArticleCardVariant.standard : ArticleCardVariant.compact)
        : variant;

    final label = article.isUnavailable
        ? '${article.title}. No longer available.'
        : '${article.title}. ${article.source}, ${TimeFormatter.relative(article.publishedAt)}. '
              '${article.likes} likes, ${article.comments} comments${article.isBookmarked ? ', saved' : ''}';

    return Semantics(
      button: true,
      container: true,
      label: label,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        // The Semantics node above is the single description of this card.
        excludeFromSemantics: true,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Opacity(
          opacity: article.isUnavailable ? 0.5 : 1,
          child: switch (effective) {
            ArticleCardVariant.lead => _LeadLayout(
              article: article,
              topicName: topicName,
              onLike: onLike,
              onBookmark: onBookmark,
            ),
            ArticleCardVariant.standard => _StandardLayout(
              article: article,
              topicName: showSectionTag ? topicName : '',
              onLike: onLike,
              onBookmark: onBookmark,
            ),
            ArticleCardVariant.compact => _CompactLayout(
              article: article,
              topicName: showSectionTag ? topicName : '',
              stacked: textScale >= 1.5,
              onLike: onLike,
              onBookmark: onBookmark,
            ),
          },
        ),
      ),
    );
  }
}

class SectionTag extends StatelessWidget {
  final String topicName;
  final bool isUnavailable;
  final Color? color;

  const SectionTag({
    super.key,
    required this.topicName,
    this.isUnavailable = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (isUnavailable) {
      return Text(
        'NO LONGER AVAILABLE',
        style: AppTextStyles.overline.copyWith(color: color ?? p.inkMuted),
      );
    }
    if (topicName.isEmpty) return const SizedBox.shrink();
    return Text(
      topicName.toUpperCase(),
      style: AppTextStyles.overline.copyWith(
        color: color ?? p.sectionTint(topicName),
      ),
    );
  }
}

class _Byline extends StatelessWidget {
  final Article article;
  final Color color;

  const _Byline({required this.article, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${article.source} · ${TimeFormatter.relative(article.publishedAt)}',
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

  const _LeadLayout({
    required this.article,
    required this.topicName,
    this.onLike,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedImage(imageUrl: article.image, borderRadius: 0),
                  // Scrim so the headline reads on any photo.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.4, 1],
                        colors: [
                          AppColors.black.withValues(alpha: 0.05),
                          AppColors.black.withValues(alpha: 0.25),
                          AppColors.black.withValues(alpha: 0.82),
                        ],
                      ),
                    ),
                  ),
                  if (topicName.isNotEmpty || article.isUnavailable)
                    Positioned(
                      left: AppSpacing.lg,
                      top: AppSpacing.lg,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusPill,
                          ),
                        ),
                        child: SectionTag(
                          topicName: topicName,
                          isUnavailable: article.isUnavailable,
                          color: AppColors.lightInk,
                        ),
                      ),
                    ),
                  Positioned(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: AppSpacing.xl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          article.title,
                          style: AppTextStyles.displayL.copyWith(
                            color: p.onImage,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          article.summary,
                          style: AppTextStyles.bodyS.copyWith(
                            color: p.onImage.withValues(alpha: 0.82),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _Byline(
                          article: article,
                          color: p.onImage.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
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

  const _StandardLayout({
    required this.article,
    required this.topicName,
    this.onLike,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasImage = article.image != null && article.image!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage) ...[
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: CachedImage(
                    imageUrl: article.image,
                    borderRadius: AppSpacing.radiusMd,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              SectionTag(
                topicName: topicName,
                isUnavailable: article.isUnavailable,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                article.title,
                style: AppTextStyles.headlineM.copyWith(color: p.ink),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                article.summary,
                style: AppTextStyles.bodyS.copyWith(color: p.inkMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              _Byline(article: article, color: p.inkMuted),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        EngagementRow(article: article, onLike: onLike, onBookmark: onBookmark),
      ],
    );
  }
}

class _CompactLayout extends StatelessWidget {
  final Article article;
  final String topicName;
  final bool stacked;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;

  const _CompactLayout({
    required this.article,
    required this.topicName,
    required this.stacked,
    this.onLike,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasImage = article.image != null && article.image!.isNotEmpty;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTag(topicName: topicName, isUnavailable: article.isUnavailable),
        const SizedBox(height: AppSpacing.sm),
        Text(
          article.title,
          style: AppTextStyles.headlineS.copyWith(color: p.ink),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),
        _Byline(article: article, color: p.inkMuted),
      ],
    );

    final thumb = hasImage
        ? CachedImage(
            imageUrl: article.image,
            width: 96,
            height: 96,
            borderRadius: AppSpacing.radiusSm,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: stacked || thumb == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (thumb != null) ...[
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: CachedImage(
                          imageUrl: article.image,
                          borderRadius: AppSpacing.radiusMd,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    text,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: text),
                    const SizedBox(width: AppSpacing.lg),
                    thumb,
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.xs),
        EngagementRow(article: article, onLike: onLike, onBookmark: onBookmark),
      ],
    );
  }
}
