import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A 44 px circular icon button on a soft surface, or blurred glass when
/// placed over imagery.
class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.glass = false,
    this.size = 44,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool glass;
  final double size;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final background = glass
        ? AppColors.black.withValues(alpha: 0.28)
        : p.surface;
    final foreground = iconColor ?? (glass ? AppColors.white : p.ink);

    Widget circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: foreground),
    );
    if (glass) {
      circle = ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: circle,
        ),
      );
    }

    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: circle,
      ),
    );
  }
}
