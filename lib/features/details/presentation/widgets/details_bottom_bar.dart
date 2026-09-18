import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../reactions/presentation/widgets/engagement_row.dart';

/// Floating action dock on the article — appears once the header scrolls
/// out of view.
class DetailsBottomBar extends StatelessWidget {
  final Article article;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final VoidCallback onShare;

  const DetailsBottomBar({
    super.key,
    required this.article,
    this.onLike,
    this.onBookmark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        0,
        AppSpacing.xxl,
        bottomInset > 0 ? bottomInset : AppSpacing.lg,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: p.isLight ? 0.12 : 0.55),
              blurRadius: 32,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: AppSpacing.dockHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              color: p.surface.withValues(alpha: p.isLight ? 0.84 : 0.8),
              child: Row(
                children: [
                  Expanded(
                    child: EngagementRow(
                      article: article,
                      onLike: onLike,
                      onBookmark: onBookmark,
                    ),
                  ),
                  Semantics(
                    button: true,
                    container: true,
                    excludeSemantics: true,
                    label: 'Share',
                    child: InkWell(
                      onTap: onShare,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.ios_share_rounded,
                            size: 20,
                            color: p.inkMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
