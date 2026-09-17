import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/hairline.dart';

/// An overline label + hairline section (Part 6.12).
class SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final inkMuted = brightness == Brightness.light ? AppColors.lightInkMuted : AppColors.darkInkMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.xxl, AppSpacing.gutter, AppSpacing.sm),
          child: Text(title.toUpperCase(), style: AppTextStyles.overline.copyWith(color: inkMuted)),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter), child: Hairline()),
        child,
      ],
    );
  }
}
