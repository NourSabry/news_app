import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum InkButtonVariant { primary, secondary, text }

/// The only button shapes in the app. Primary is an ink fill, secondary a
/// soft surface fill, text is bare.
class InkButton extends StatelessWidget {
  const InkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = InkButtonVariant.primary,
    this.expand = true,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final InkButtonVariant variant;
  final bool expand;
  final Widget? leading;

  bool get _disabled => onPressed == null;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final labelColor = _disabled
        ? p.inkFaint
        : variant == InkButtonVariant.primary
        ? p.background
        : p.ink;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: labelColor,
              fontSize: 15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final Widget button = switch (variant) {
      InkButtonVariant.primary => _Shell(
        height: 54,
        expand: expand,
        color: _disabled ? p.surfaceHigh : p.ink,
        onTap: onPressed,
        child: content,
      ),
      InkButtonVariant.secondary => _Shell(
        height: 54,
        expand: expand,
        color: p.surface,
        onTap: onPressed,
        child: content,
      ),
      InkButtonVariant.text => _Shell(
        height: 44,
        expand: false,
        color: Colors.transparent,
        onTap: onPressed,
        child: content,
      ),
    };

    return Semantics(
      button: true,
      container: true,
      enabled: !_disabled,
      label: label,
      excludeSemantics: true,
      child: button,
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({
    required this.height,
    required this.expand,
    required this.color,
    required this.onTap,
    required this.child,
  });

  final double height;
  final bool expand;
  final Color color;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
