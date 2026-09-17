import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/hairline.dart';
import '../../../../core/widgets/ink_button.dart';
import '../../domain/outbox_conflict.dart';

/// Lists what the server rejected on sync because its own state had moved
/// on (X1). The sync response has no "force", so there's only one
/// resolution — keep the server's value, already applied by the time this
/// shows — this just tells the reader what changed.
class ConflictReviewSheet extends StatelessWidget {
  final List<OutboxConflict> conflicts;

  const ConflictReviewSheet({super.key, required this.conflicts});

  static Future<void> show(BuildContext context, List<OutboxConflict> conflicts) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConflictReviewSheet(conflicts: conflicts),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final paperRaised = isLight ? AppColors.lightPaperRaised : AppColors.darkPaperRaised;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: paperRaised),
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Hairline(),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      conflicts.length == 1 ? '1 change was updated' : '${conflicts.length} changes were updated',
                      style: AppTextStyles.headlineM.copyWith(color: ink),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final conflict in conflicts) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Text.rich(
                          _messageFor(conflict, ink, inkMuted),
                          style: AppTextStyles.body.copyWith(color: inkMuted),
                        ),
                      ),
                      const Hairline(),
                    ],
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.lg),
              child: InkButton(
                label: 'Keep server',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _messageFor(OutboxConflict conflict, Color ink, Color inkMuted) {
    final likeVerb = conflict.serverIsLiked ? 'liked' : 'unliked';
    final likeState = conflict.serverIsLiked ? 'already liked' : 'no longer liked';
    return TextSpan(
      children: [
        TextSpan(text: 'You $likeVerb '),
        TextSpan(
          text: conflict.articleTitle,
          style: AppTextStyles.body.copyWith(color: ink, fontStyle: FontStyle.italic),
        ),
        TextSpan(
          text: ' offline; it now has ${conflict.serverLikes} likes and is $likeState.',
        ),
      ],
    );
  }
}
