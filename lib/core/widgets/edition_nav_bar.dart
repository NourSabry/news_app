import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_text_styles.dart';
import 'double_rule.dart';

class EditionNavBarItem {
  const EditionNavBarItem({
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

/// Replaces `BottomNavigationBar`/`NavigationBar` entirely (Part 6.11):
/// 64 px + safe area, `paperRaised`, a double rule on top (the second and
/// last use of the double rule), and a 16×2 red rule that slides between
/// the active item's label.
class EditionNavBar extends StatelessWidget {
  const EditionNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.visible = true,
  });

  final List<EditionNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final paperRaised = isLight ? AppColors.lightPaperRaised : AppColors.darkPaperRaised;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkFaint = isLight ? AppColors.lightInkFaint : AppColors.darkInkFaint;
    final red = isLight ? AppColors.lightRed : AppColors.darkRed;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnimatedSlide(
      duration: AppMotion.scaled(context, AppMotion.transition),
      curve: AppMotion.curveIn,
      offset: visible ? Offset.zero : const Offset(0, 1),
      child: Container(
        color: paperRaised,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DoubleRule(),
            SizedBox(
              height: 64,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / items.length;
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: AppMotion.scaled(context, AppMotion.transition),
                        curve: AppMotion.curveIn,
                        left: itemWidth * currentIndex + itemWidth / 2 - 8,
                        bottom: 8,
                        child: Container(width: 16, height: 2, color: red),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            Expanded(
                              child: _NavItem(
                                item: items[i],
                                selected: i == currentIndex,
                                ink: ink,
                                inkFaint: inkFaint,
                                red: red,
                                onTap: () => onTap(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.ink,
    required this.inkFaint,
    required this.red,
    required this.onTap,
  });

  final EditionNavBarItem item;
  final bool selected;
  final Color ink;
  final Color inkFaint;
  final Color red;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? item.filledIcon : item.outlineIcon,
                  size: 24,
                  color: selected ? ink : inkFaint,
                ),
                if (item.showDot)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.label.toUpperCase(),
              style: AppTextStyles.overline.copyWith(
                color: selected ? ink : inkFaint,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
