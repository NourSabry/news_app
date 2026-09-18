import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';

/// Page indicator: small dots, the active one stretched into a pill.
class PageDots extends StatelessWidget {
  final int count;
  final int index;

  const PageDots({super.key, required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          AnimatedContainer(
            duration: AppMotion.scaled(context, AppMotion.transition),
            curve: AppMotion.curveSettle,
            width: i == index ? 24 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index ? p.ink : p.surfaceHigh,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ],
    );
  }
}
