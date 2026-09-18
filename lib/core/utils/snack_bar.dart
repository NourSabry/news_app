import 'package:flutter/material.dart';
import '../widgets/edition_snack_bar.dart';

void showSnackBarMessage(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  EditionSnackBar.show(
    context,
    message,
    actionLabel: action?.label,
    onAction: action?.onPressed,
  );
}
