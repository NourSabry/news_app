import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';

/// One topic tile: a photo from that section under a dark scrim, the name
/// in serif, and a check that fills in when selected.
class SectionTile extends StatelessWidget {
  final Topic topic;
  final bool isSelected;
  final int? articleCount;
  final String? coverUrl;
  final VoidCallback onTap;

  const SectionTile({
    super.key,
    required this.topic,
    required this.isSelected,
    required this.onTap,
    this.articleCount,
    this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tint = p.sectionTint(topic.name);
    final duration = AppMotion.scaled(context, AppMotion.transition);

    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      selected: isSelected,
      label: topic.name,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          duration: duration,
          curve: AppMotion.curveSettle,
          scale: isSelected ? 1 : 0.97,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (coverUrl != null)
                  CachedImage(imageUrl: coverUrl, borderRadius: 0)
                else
                  ColoredBox(
                    color: Color.alphaBlend(
                      tint.withValues(alpha: 0.25),
                      p.surface,
                    ),
                  ),
                AnimatedContainer(
                  duration: duration,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.black.withValues(
                          alpha: isSelected ? 0.15 : 0.35,
                        ),
                        AppColors.black.withValues(
                          alpha: isSelected ? 0.75 : 0.85,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: AnimatedContainer(
                          duration: duration,
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withValues(
                                alpha: isSelected ? 0 : 0.7,
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: AppColors.lightInk,
                                )
                              : null,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        topic.name,
                        style: AppTextStyles.headlineM.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      if (articleCount != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$articleCount ${articleCount == 1 ? 'story' : 'stories'} this week',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
