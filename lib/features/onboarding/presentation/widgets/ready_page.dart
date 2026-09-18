import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../feed/presentation/widgets/article_cards.dart';

/// Screen 3 — a live, non-interactive preview of the real feed for the
/// sections just chosen.
class ReadyPage extends StatelessWidget {
  final List<Article> preview;
  final List<Topic> topics;
  final bool isLoading;

  const ReadyPage({
    super.key,
    required this.preview,
    required this.topics,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gutter,
        vertical: AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your edition\nis ready.',
            style: AppTextStyles.displayXL.copyWith(color: p.ink),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "Here's a first look. Pull down any time for what's new.",
            style: AppTextStyles.body.copyWith(color: p.inkMuted),
          ),
          const SizedBox(height: AppSpacing.xxl),
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: isLoading || preview.isEmpty
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LeadCardSkeleton(),
                        SizedBox(height: AppSpacing.xl),
                        CompactCardSkeleton(),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < preview.length && i < 2; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.xl),
                          EditionArticleCard(
                            article: preview[i],
                            topicName: topics.nameFor(preview[i].topicId),
                            variant: i == 0
                                ? ArticleCardVariant.lead
                                : ArticleCardVariant.compact,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
