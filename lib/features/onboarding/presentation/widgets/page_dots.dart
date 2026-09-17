import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';

/// Three 6 px ink dots; the active page is a 20 px red rule (Part 6.5).
class PageDots extends StatelessWidget {
  final int count;
  final int index;

  const PageDots({super.key, required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final red = isLight ? AppColors.lightRed : AppColors.darkRed;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          AnimatedContainer(
            duration: AppMotion.scaled(context, AppMotion.transition),
            curve: AppMotion.curveIn,
            width: i == index ? 20 : 6,
            height: i == index ? 2 : 6,
            decoration: BoxDecoration(
              color: i == index ? red : ink,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ],
    );
  }
}
