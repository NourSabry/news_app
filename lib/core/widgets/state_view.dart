import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'ink_button.dart';

/// Shared layout for empty, error, offline and unavailable states: a large
/// glyph on a soft disc, a serif title, one line of explanation, actions.
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  /// Tints the disc with the accent instead of the neutral surface.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxxl,
          0,
          AppSpacing.xxxl,
          AppSpacing.dockClearance,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: accent ? p.accentSoft : p.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: accent ? p.accent : p.ink),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineM.copyWith(color: p.ink),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: p.inkMuted),
            ),
            if (primaryActionLabel != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              InkButton(
                label: primaryActionLabel!,
                onPressed: onPrimaryAction,
                expand: false,
              ),
            ],
            if (secondaryActionLabel != null) ...[
              const SizedBox(height: AppSpacing.xs),
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
