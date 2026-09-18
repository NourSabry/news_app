import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A titled group of settings on a soft rounded surface.
class SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.xxl,
        AppSpacing.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.md,
            ),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.overline.copyWith(color: p.inkMuted),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: ColoredBox(
              color: p.surface,
              child: ListTileTheme(
                data: ListTileThemeData(
                  iconColor: p.ink,
                  textColor: p.ink,
                  titleTextStyle: AppTextStyles.body.copyWith(color: p.ink),
                  subtitleTextStyle: AppTextStyles.caption.copyWith(
                    color: p.inkMuted,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 2,
                  ),
                  minVerticalPadding: AppSpacing.md,
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
