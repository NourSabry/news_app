import 'package:flutter/material.dart';

class BookmarkButton extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback? onTap;
  final ButtonStyle? style;
  final bool compact;

  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    this.onTap,
    this.style,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = IconButton.styleFrom(foregroundColor: colors.primary).merge(style);
    final inactive = style ?? IconButton.styleFrom(foregroundColor: colors.onSurfaceVariant);
    return IconButton(
      tooltip: isBookmarked ? 'Remove bookmark' : 'Save',
      style: isBookmarked ? active : inactive,
      padding: compact ? EdgeInsets.zero : null,
      constraints: compact ? const BoxConstraints.tightFor(width: 36, height: 36) : null,
      icon: Icon(isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded),
      onPressed: onTap,
    );
  }
}
