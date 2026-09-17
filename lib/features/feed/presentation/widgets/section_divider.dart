import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/hairline.dart';

/// "MORE IN TECHNOLOGY" between runs of same-topic cards (Part 6.6).
class SectionDivider extends StatelessWidget {
  final String topicName;

  const SectionDivider({super.key, required this.topicName});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final inkFaint = brightness == Brightness.light ? AppColors.lightInkFaint : AppColors.darkInkFaint;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MORE IN ${topicName.toUpperCase()}', style: AppTextStyles.overline.copyWith(color: inkFaint)),
          const SizedBox(height: AppSpacing.sm),
          const Hairline(),
        ],
      ),
    );
  }
}
