import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/hairline.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../feed/presentation/widgets/article_cards.dart';

/// Screen 3 — a live, non-interactive preview of the real feed (Part 6.5).
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
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;
    final paper = isLight ? AppColors.lightPaper : AppColors.darkPaper;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Your first edition is ready.', style: AppTextStyles.displayL.copyWith(color: ink)),
          const SizedBox(height: AppSpacing.xl),
          IgnorePointer(
            child: FractionallySizedBox(
              widthFactor: 0.85,
              child: Container(
                decoration: BoxDecoration(color: paper, border: Border.all(color: ink)),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: isLoading
                    ? const HomeFeedSkeleton(standardCount: 1)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < preview.length; i++) ...[
                            if (i > 0) ...[const SizedBox(height: AppSpacing.lg), const Hairline(), const SizedBox(height: AppSpacing.lg)],
                            EditionArticleCard(
                              article: preview[i],
                              topicName: topics.nameFor(preview[i].topicId),
                              variant: i == 0 ? ArticleCardVariant.lead : ArticleCardVariant.standard,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Updated every time you pull down.', style: AppTextStyles.caption.copyWith(color: inkMuted)),
        ],
      ),
    );
  }
}
