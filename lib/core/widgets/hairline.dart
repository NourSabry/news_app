import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A 1 px logical divider line in `rule` (Part 6.3). The paper's substitute
/// for card shadows and borders.
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.color, this.vertical = false});

  final Color? color;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final resolved =
        color ?? (brightness == Brightness.light ? AppColors.lightRule : AppColors.darkRule);
    return vertical ? Container(width: 1, color: resolved) : Container(height: 1, color: resolved);
  }
}
