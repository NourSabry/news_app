import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum EditionPillVariant { tonal, filled }

/// The one chip shape in the app: a soft surface pill, or an ink-filled
/// pill when selected/applied. Optional leading icon and removable ✕.
class EditionPill extends StatelessWidget {
  const EditionPill({
    super.key,
    required this.label,
    this.variant = EditionPillVariant.tonal,
    this.onTap,
    this.onRemove,
    this.leadingIcon,
    this.leadingDot = false,
    this.height = 38,
  });

  final String label;
  final EditionPillVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final IconData? leadingIcon;
  final bool leadingDot;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final filled = variant == EditionPillVariant.filled;
    final textColor = filled ? p.background : p.ink;
    final background = filled ? p.ink : p.surface;

    final pill = AnimatedContainer(
      duration: AppMotion.scaled(context, AppMotion.micro),
      height: height,
      padding: EdgeInsets.only(
        left: leadingIcon != null || leadingDot ? AppSpacing.md : AppSpacing.lg,
        right: onRemove != null ? AppSpacing.sm : AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: p.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 16, color: textColor),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(label, style: AppTextStyles.label.copyWith(color: textColor)),
          if (onRemove != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Semantics(
              button: true,
              container: true,
              excludeSemantics: true,
              label: 'Remove $label filter',
              child: GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(Icons.close_rounded, size: 16, color: textColor),
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
      selected: filled,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: pill,
      ),
    );
  }
}
