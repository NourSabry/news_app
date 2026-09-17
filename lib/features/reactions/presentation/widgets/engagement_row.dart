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

  const EngagementRow({super.key, required this.article, this.onLike, this.onBookmark});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkFaint = isLight ? AppColors.lightInkFaint : AppColors.darkInkFaint;

    return Row(
      children: [
        _LikeButton(isLiked: article.isLiked, count: article.likes, onTap: onLike),
        const SizedBox(width: AppSpacing.lg),
        Icon(Icons.mode_comment_outlined, size: 18, color: inkFaint),
        const SizedBox(width: AppSpacing.xs),
        Text(
          NumberFormat.compact().format(article.comments),
          style: AppTextStyles.label.copyWith(color: inkFaint),
        ),
        const Spacer(),
        Semantics(
          button: true,
          label: article.isBookmarked ? 'Remove from saved' : 'Save for later',
          child: InkWell(
            onTap: onBookmark,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Icon(
                article.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                size: 20,
                color: article.isBookmarked ? ink : inkFaint,
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

class _LikeButtonState extends State<_LikeButton> with SingleTickerProviderStateMixin {
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
    final red = isLight ? AppColors.lightRed : AppColors.darkRed;

    return Semantics(
      button: true,
      label: widget.isLiked ? 'Unlike' : 'Like',
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
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
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: red, width: 1.5)),
                        ),
                      ),
                    Transform.scale(
                      scale: MediaQuery.disableAnimationsOf(context) ? 1.0 : _scale.value,
                      child: child,
                    ),
                  ],
                ),
                child: Icon(
                  widget.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 18,
                  color: widget.isLiked ? red : inkFaint,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                NumberFormat.compact().format(widget.count),
                style: AppTextStyles.label.copyWith(
                  color: widget.isLiked ? red : inkFaint,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
