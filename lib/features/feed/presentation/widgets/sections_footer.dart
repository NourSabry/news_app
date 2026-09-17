import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "3 sections · Edit" at the end of the feed (Part 6.6) — not a header,
/// the user already chose their sections in onboarding/Settings.
class SectionsFooter extends StatelessWidget {
  final int count;
  final VoidCallback onEdit;

  const SectionsFooter({super.key, required this.count, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final inkMuted = brightness == Brightness.light ? AppColors.lightInkMuted : AppColors.darkInkMuted;
    final ink = brightness == Brightness.light ? AppColors.lightInk : AppColors.darkInk;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.xxl),
      child: Center(
        child: InkWell(
          onTap: onEdit,
          child: Text.rich(
            TextSpan(
              style: AppTextStyles.caption.copyWith(color: inkMuted),
              children: [
                TextSpan(text: '$_label · '),
                TextSpan(text: 'Edit', style: TextStyle(color: ink, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _label {
    if (count == 0) return 'All sections';
    return '$count ${count == 1 ? 'section' : 'sections'}';
  }
}
