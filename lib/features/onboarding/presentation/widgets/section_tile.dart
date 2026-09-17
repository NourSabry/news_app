import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/halftone_painter.dart';

/// One topic tile in the onboarding sections grid (Part 6.5).
class SectionTile extends StatelessWidget {
  final Topic topic;
  final bool isSelected;
  final int? articleCount;
  final VoidCallback onTap;

  const SectionTile({
    super.key,
    required this.topic,
    required this.isSelected,
    required this.onTap,
    this.articleCount,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final paperRaised = isLight ? AppColors.lightPaperRaised : AppColors.darkPaperRaised;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkFaint = isLight ? AppColors.lightInkFaint : AppColors.darkInkFaint;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;
    final tint = AppColors.sectionTint(topic.name, brightness);

    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      selected: isSelected,
      label: topic.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusImage),
        child: AnimatedOpacity(
          duration: AppMotion.scaled(context, AppMotion.transition),
          opacity: isSelected ? 1 : 0.7,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Color.alphaBlend(tint.withValues(alpha: 0.12), paperRaised) : paperRaised,
              borderRadius: BorderRadius.circular(AppSpacing.radiusImage),
              border: Border(left: BorderSide(color: isSelected ? tint : inkFaint, width: 4)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: Halftone(shape: HalftoneShape.radial, size: 64, tint: tint, opacity: 0.5),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: isSelected
                            ? Icon(Icons.check_rounded, size: 18, color: ink)
                            : const SizedBox(height: 18),
                      ),
                      Text(topic.name, style: AppTextStyles.headlineM.copyWith(color: ink)),
                      if (articleCount != null)
                        Text(
                          '$articleCount ${articleCount == 1 ? 'story' : 'stories'} this week',
                          // inkMuted, not inkFaint (G6/T4) — see engagement_row.
                          style: AppTextStyles.caption.copyWith(color: inkMuted),
                        ),
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
