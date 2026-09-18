import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// System / Light / Dark as a segmented pill control.
class ThemeModeSelector extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  const ThemeModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _options = [
    (ThemeMode.system, 'System', Icons.brightness_auto_rounded),
    (ThemeMode.light, 'Light', Icons.light_mode_rounded),
    (ThemeMode.dark, 'Dark', Icons.dark_mode_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Appearance', style: AppTextStyles.body.copyWith(color: p.ink)),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: p.background,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Row(
              children: [
                for (final (mode, label, icon) in _options)
                  Expanded(
                    child: Semantics(
                      button: true,
                      container: true,
                      excludeSemantics: true,
                      selected: value == mode,
                      label: label,
                      child: GestureDetector(
                        onTap: () => onChanged(mode),
                        child: AnimatedContainer(
                          duration: AppMotion.scaled(
                            context,
                            AppMotion.transition,
                          ),
                          curve: AppMotion.curveSettle,
                          height: 40,
                          decoration: BoxDecoration(
                            color: value == mode ? p.ink : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icon,
                                size: 16,
                                color: value == mode
                                    ? p.background
                                    : p.inkMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                label,
                                style: AppTextStyles.label.copyWith(
                                  color: value == mode
                                      ? p.background
                                      : p.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
