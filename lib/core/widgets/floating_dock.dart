import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class FloatingDockItem {
  const FloatingDockItem({
    required this.outlineIcon,
    required this.filledIcon,
    required this.label,
    this.showDot = false,
  });

  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;
  final bool showDot;
}

/// Bottom navigation as a floating, blurred dock inset from the screen
/// edges. The active item expands into an ink capsule with its label;
/// inactive items are icon-only.
class FloatingDock extends StatelessWidget {
  const FloatingDock({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.visible = true,
  });

  final List<FloatingDockItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnimatedSlide(
      duration: AppMotion.scaled(context, AppMotion.transition),
      curve: AppMotion.curveIn,
      offset: visible ? Offset.zero : const Offset(0, 1.5),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          0,
          AppSpacing.xxl,
          bottomInset > 0 ? bottomInset : AppSpacing.lg,
        ),
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(
                    alpha: p.isLight ? 0.12 : 0.55,
                  ),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: AppSpacing.dockHeight,
                  padding: const EdgeInsets.all(6),
                  color: p.surface.withValues(alpha: p.isLight ? 0.84 : 0.8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        _DockItem(
                          item: items[i],
                          selected: i == currentIndex,
                          onTap: () => onTap(i),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FloatingDockItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final duration = AppMotion.scaled(context, AppMotion.transition);

    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: duration,
          curve: AppMotion.curveSettle,
          height: 52,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? AppSpacing.xl : AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: selected ? p.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    selected ? item.filledIcon : item.outlineIcon,
                    size: 22,
                    color: selected ? p.background : p.inkMuted,
                  ),
                  if (item.showDot)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: p.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? p.ink : p.surface,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              AnimatedSize(
                duration: duration,
                curve: AppMotion.curveSettle,
                alignment: Alignment.centerLeft,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: Text(
                          item.label,
                          style: AppTextStyles.label.copyWith(
                            color: p.background,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
