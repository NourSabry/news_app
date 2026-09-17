import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// The newspaper signature: 1 px `ruleStrong`, 3 px gap, 1 px `ruleStrong`
/// (Part 6.3). Used exactly twice in the app — under the masthead and
/// above the bottom nav.
class DoubleRule extends StatelessWidget {
  const DoubleRule({
    super.key,
    this.animate = false,
    this.duration = const Duration(milliseconds: 600),
  });

  /// Draws itself left-to-right over [duration] (onboarding screen 1 only).
  final bool animate;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color =
        brightness == Brightness.light ? AppColors.lightRuleStrong : AppColors.darkRuleStrong;
    final rules = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 1, color: color),
        const SizedBox(height: 3),
        Container(height: 1, color: color),
      ],
    );

    if (!animate || MediaQuery.disableAnimationsOf(context)) return rules;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: AppMotion.curveIn,
      builder: (context, value, child) => ClipRect(
        child: Align(alignment: Alignment.centerLeft, widthFactor: value, child: child),
      ),
      child: rules,
    );
  }
}
