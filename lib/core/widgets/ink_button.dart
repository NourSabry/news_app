import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum InkButtonVariant { primary, secondary, text }

/// The only button shapes in the app (Part 6.0, 6.5). No stock
/// `ElevatedButton`/`TextButton` styling.
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
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final paper = isLight ? AppColors.lightPaper : AppColors.darkPaper;
    final rule = isLight ? AppColors.lightRule : AppColors.darkRule;
    final inkFaint = isLight ? AppColors.lightInkFaint : AppColors.darkInkFaint;

    final labelColor = _disabled
        ? inkFaint
        : variant == InkButtonVariant.primary
            ? paper
            : ink;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.sm)],
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(color: labelColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final Widget button = switch (variant) {
      InkButtonVariant.primary => _Shell(
          height: 52,
          expand: expand,
          color: _disabled ? rule : ink,
          border: null,
          onTap: onPressed,
          child: content,
        ),
      InkButtonVariant.secondary => _Shell(
          height: 52,
          expand: expand,
          color: Colors.transparent,
          border: Border.all(color: _disabled ? rule : ink),
          onTap: onPressed,
          child: content,
        ),
      InkButtonVariant.text => _Shell(
          height: 44,
          expand: false,
          color: Colors.transparent,
          border: null,
          onTap: onPressed,
          child: content,
        ),
    };

    return Semantics(
      button: true,
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
    required this.border,
    required this.onTap,
    required this.child,
  });

  final double height;
  final bool expand;
  final Color color;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusImage),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusImage),
          child: Container(
            decoration: BoxDecoration(
              border: border,
              borderRadius: BorderRadius.circular(AppSpacing.radiusImage),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
