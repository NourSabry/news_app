import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The single snackbar surface (Part 6.0): themed via `AppTheme.snackBarTheme`
/// (ink fill, paper text, 4 px radius) — never stock Material grey.
sealed class EditionSnackBar {
  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final brightness = Theme.of(context).brightness;
    final red = brightness == Brightness.light ? AppColors.lightRed : AppColors.darkRed;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: actionLabel != null
            ? SnackBarAction(label: actionLabel, textColor: red, onPressed: onAction ?? () {})
            : null,
      ),
    );
  }
}
