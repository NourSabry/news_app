import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// The like / comment / bookmark row under every card and on the details
/// sticky bar (Part 6.6): outline/filled ink→red heart with a tap
/// ink-splash, comment glyph, right-aligned bookmark glyph.
class EngagementRow extends StatelessWidget {
  final Article article;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;

  const EngagementRow({
    super.key,
    required this.article,
    this.onLike,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkFaint = isLight ? AppColors.lightInkFaint : AppColors.darkInkFaint;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;

    return Row(
      children: [
        _LikeButton(
          isLiked: article.isLiked,
          count: article.likes,
          onTap: onLike,
        ),
        const SizedBox(width: AppSpacing.lg),
        // Its own informational node (G6) rather than merging into
        // whatever ancestor Semantics happens to wrap this row — on a
        // card that's already redundant with the card's own label, but
        // on Details (no such ancestor) it's the only source of this info.
        Semantics(
          container: true,
          excludeSemantics: true,
          label: '${article.comments} ${article.comments == 1 ? 'comment' : 'comments'}',
          child: ExcludeSemantics(
            child: Row(
              children: [
                Icon(Icons.mode_comment_outlined, size: 18, color: inkFaint),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  NumberFormat.compact().format(article.comments),
                  // inkMuted, not inkFaint (G6/T4) — inkFaint doesn't meet
                  // WCAG AA against paper at this size; reserve it for
                  // purely decorative icons.
                  style: AppTextStyles.label.copyWith(color: inkMuted),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Semantics(
          button: true,
          container: true,
          excludeSemantics: true,
          label: article.isBookmarked ? 'Remove from saved' : 'Save for later',
          onTapHint: article.isBookmarked ? 'remove from saved' : 'save for later',
          child: InkWell(
            onTap: onBookmark,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: ConstrainedBox(
              // 48×48 tap target (G6/T4, androidTapTargetGuideline) — the
              // visual glyph stays 20px, just centred in a bigger hit area.
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Center(
                child: Icon(
                  article.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  size: 20,
                  color: article.isBookmarked ? ink : inkFaint,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LikeButton extends StatefulWidget {
  final bool isLiked;
  final int count;
  final VoidCallback? onTap;

  const _LikeButton({required this.isLiked, required this.count, this.onTap});

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _scale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    _controller.forward(from: 0);
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final inkFaint = isLight ? AppColors.lightInkFaint : AppColors.darkInkFaint;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;
    final red = isLight ? AppColors.lightRed : AppColors.darkRed;

    final inFlight = widget.onTap == null;

    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      label: widget.isLiked ? 'Unlike' : 'Like',
      onTapHint: widget.isLiked ? 'unlike' : 'like',
      child: InkWell(
        onTap: inFlight ? null : _handleTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: ConstrainedBox(
          // 48×48 tap target (G6/T4, androidTapTargetGuideline) — the
          // visual row (icon + count) is unchanged, just centred taller.
          constraints: const BoxConstraints(minHeight: 48),
          child: Center(
            child: Opacity(
              // A subtle pressed look while the toggle is in flight — never
              // a spinner (G2).
              opacity: inFlight ? 0.5 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) => Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_controller.isAnimating)
                            Opacity(
                              opacity: (1 - _controller.value).clamp(0.0, 1.0),
                              child: Container(
                                width: 28 * _scale.value,
                                height: 28 * _scale.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: red, width: 1.5),
                                ),
                              ),
                            ),
                          Transform.scale(
                            scale: MediaQuery.disableAnimationsOf(context)
                                ? 1.0
                                : _scale.value,
                            child: child,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: widget.isLiked ? red : inkFaint,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      NumberFormat.compact().format(widget.count),
                      style: AppTextStyles.label.copyWith(
                        // inkMuted, not inkFaint (G6/T4) — see the comment
                        // count above.
                        color: widget.isLiked ? red : inkMuted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
