import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/hairline.dart';
import '../../../reactions/presentation/widgets/engagement_row.dart';

/// Sticky bottom bar — appears after the header scrolls out (Part 6.9).
class DetailsBottomBar extends StatelessWidget {
  final Article article;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final VoidCallback onShare;

  const DetailsBottomBar({
    super.key,
    required this.article,
    this.onLike,
    this.onBookmark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final paperRaised = isLight ? AppColors.lightPaperRaised : AppColors.darkPaperRaised;
    final inkFaint = isLight ? AppColors.lightInkFaint : AppColors.darkInkFaint;

    return DecoratedBox(
      decoration: BoxDecoration(color: paperRaised),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Hairline(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: EngagementRow(article: article, onLike: onLike, onBookmark: onBookmark)),
                  Semantics(
                    button: true,
                    label: 'Share',
                    child: InkWell(
                      onTap: onShare,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        child: Icon(Icons.ios_share_rounded, size: 20, color: inkFaint),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
