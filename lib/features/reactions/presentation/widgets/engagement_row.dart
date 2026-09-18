import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Like, comment count and bookmark under every card and on the article
/// action bar.
class EngagementRow extends StatelessWidget {
  final Article article;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;

  /// Renders on top of imagery or an ink surface instead of the page.
  final Color? foreground;

  const EngagementRow({
    super.key,
    required this.article,
    this.onLike,
    this.onBookmark,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final base = foreground ?? p.inkMuted;

    return Row(
      children: [
        LikeButton(
          isLiked: article.isLiked,
          count: article.likes,
          onTap: onLike,
          foreground: base,
        ),
        const SizedBox(width: AppSpacing.sm),
        Semantics(
          container: true,
          excludeSemantics: true,
          label:
              '${article.comments} ${article.comments == 1 ? 'comment' : 'comments'}',
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: base,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    NumberFormat.compact().format(article.comments),
                    style: AppTextStyles.label.copyWith(
                      color: base,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        Semantics(
          button: true,
          container: true,
          excludeSemantics: true,
          label: article.isBookmarked ? 'Remove from saved' : 'Save for later',
          onTapHint: article.isBookmarked
              ? 'remove from saved'
              : 'save for later',
          child: InkWell(
            onTap: onBookmark,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Center(
                child: Icon(
                  article.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  size: 22,
                  color: article.isBookmarked ? (foreground ?? p.ink) : base,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LikeButton extends StatefulWidget {
  final bool isLiked;
  final int count;
  final VoidCallback? onTap;
  final Color foreground;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.count,
    required this.foreground,
    this.onTap,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );
  late final Animation<double> _scale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
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
    final p = context.palette;
    final inFlight = widget.onTap == null;
    final color = widget.isLiked ? p.accent : widget.foreground;

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
          constraints: const BoxConstraints(minHeight: 48),
          child: Center(
            child: Opacity(
              // Pressed look while the toggle is in flight; never a spinner.
              opacity: inFlight ? 0.5 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
                                width: 30 * _scale.value,
                                height: 30 * _scale.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: p.accent.withValues(alpha: 0.18),
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
                            : Icons.favorite_outline_rounded,
                        size: 20,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      NumberFormat.compact().format(widget.count),
                      style: AppTextStyles.label.copyWith(
                        color: color,
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
