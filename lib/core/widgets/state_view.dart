import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'halftone_painter.dart';
import 'ink_button.dart';

/// The shared full-screen layout for every empty/error/offline/unavailable
/// state (Part 6.10): halftone → title → body → actions.
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.shape,
    required this.title,
    required this.body,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.halftoneOpacity = 1,
  });

  final HalftoneShape shape;
  final String title;
  final String body;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final double halftoneOpacity;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Halftone(shape: shape, opacity: halftoneOpacity),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineM.copyWith(color: ink),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: inkMuted),
            ),
            if (primaryActionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              InkButton(
                label: primaryActionLabel!,
                onPressed: onPrimaryAction,
                expand: false,
              ),
            ],
            if (secondaryActionLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              InkButton(
                label: secondaryActionLabel!,
                onPressed: onSecondaryAction,
                variant: InkButtonVariant.text,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
