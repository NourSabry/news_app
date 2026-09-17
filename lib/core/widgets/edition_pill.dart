import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum EditionPillVariant { outlined, filled }

/// Replaces Material `Chip` everywhere (Part 6.0, 6.7, 6.9): ink-outlined
/// or ink-filled radius-999 pill, with an optional leading red dot and a
/// removable trailing ✕.
class EditionPill extends StatelessWidget {
  const EditionPill({
    super.key,
    required this.label,
    this.variant = EditionPillVariant.outlined,
    this.onTap,
    this.onRemove,
    this.leadingDot = false,
  });

  final String label;
  final EditionPillVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool leadingDot;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final paper = isLight ? AppColors.lightPaper : AppColors.darkPaper;
    final red = isLight ? AppColors.lightRed : AppColors.darkRed;
    final filled = variant == EditionPillVariant.filled;
    final textColor = filled ? paper : ink;

    final pill = Container(
      padding: EdgeInsets.only(
        left: leadingDot ? AppSpacing.sm : AppSpacing.md,
        right: onRemove != null ? AppSpacing.xs : AppSpacing.md,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: filled ? ink : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: filled ? null : Border.all(color: ink),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingDot) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: red, shape: BoxShape.circle)),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label, style: AppTextStyles.label.copyWith(color: textColor)),
          if (onRemove != null) ...[
            const SizedBox(width: AppSpacing.xs),
            GestureDetector(
              onTap: onRemove,
              child: Semantics(
                button: true,
                container: true,
                excludeSemantics: true,
                label: 'Remove $label filter',
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(Icons.close, size: 14, color: textColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return pill;

    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      label: label,
      child: GestureDetector(onTap: onTap, child: pill),
    );
  }
}
