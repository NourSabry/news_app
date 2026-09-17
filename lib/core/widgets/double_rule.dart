import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The newspaper signature: 1 px `ruleStrong`, 3 px gap, 1 px `ruleStrong`
/// (Part 6.3). Used exactly twice in the app — under the masthead and
/// above the bottom nav. Nowhere else.
class DoubleRule extends StatelessWidget {
  const DoubleRule({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color =
        brightness == Brightness.light ? AppColors.lightRuleStrong : AppColors.darkRuleStrong;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 1, color: color),
        const SizedBox(height: 3),
        Container(height: 1, color: color),
      ],
    );
  }
}
