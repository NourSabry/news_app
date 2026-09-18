import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class PaginationFooter extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasMore;

  const PaginationFooter({
    super.key,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Center(
        child: isLoadingMore
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(p.inkMuted),
                ),
              )
            : hasMore
            ? const SizedBox.shrink()
            : Text(
                "You're all caught up",
                style: AppTextStyles.caption.copyWith(color: p.inkFaint),
              ),
      ),
    );
  }
}
