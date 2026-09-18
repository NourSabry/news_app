import 'package:flutter/material.dart';

/// The single snackbar surface, styled through `AppTheme.snackBarTheme`.
sealed class EditionSnackBar {
  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 96),
        action: actionLabel != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction ?? () {})
            : null,
      ),
    );
  }
}
