import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ink_button.dart';
import '../../domain/outbox_conflict.dart';

/// Lists what the server rejected on sync because its own state had moved
/// on. The sync response has no "force", so there's only one resolution —
/// keep the server's value, already applied by the time this shows. This
/// just tells the reader what changed.
class ConflictReviewSheet extends StatelessWidget {
  final List<OutboxConflict> conflicts;

  const ConflictReviewSheet({super.key, required this.conflicts});

  static Future<void> show(
    BuildContext context,
    List<OutboxConflict> conflicts,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConflictReviewSheet(conflicts: conflicts),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: p.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: p.surfaceHigh,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.xl,
                AppSpacing.gutter,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: p.accentSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sync_problem_rounded,
                      size: 20,
                      color: p.accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      conflicts.length == 1
                          ? 'One change was updated'
                          : '${conflicts.length} changes were updated',
                      style: AppTextStyles.headlineM.copyWith(color: p.ink),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.sm,
                  AppSpacing.gutter,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final conflict in conflicts)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: p.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                        child: Text.rich(
                          _messageFor(conflict, p.ink),
                          style: AppTextStyles.bodyS.copyWith(
                            color: p.inkMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.lg,
                AppSpacing.gutter,
                AppSpacing.lg,
              ),
              child: InkButton(
                label: 'Got it',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _messageFor(OutboxConflict conflict, Color ink) {
    final likeVerb = conflict.serverIsLiked ? 'liked' : 'unliked';
    final likeState = conflict.serverIsLiked
        ? 'already liked'
        : 'no longer liked';
    return TextSpan(
      children: [
        TextSpan(text: 'You $likeVerb '),
        TextSpan(
          text: conflict.articleTitle,
          style: AppTextStyles.bodyS.copyWith(
            color: ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextSpan(
          text:
              ' while offline. It now has ${conflict.serverLikes} likes and is $likeState.',
        ),
      ],
    );
  }
}
