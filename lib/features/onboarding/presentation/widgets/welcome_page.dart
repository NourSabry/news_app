import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';

/// Screen 1 — a fanned collage of today's real story photos settles into
/// place above the title.
class WelcomePage extends StatefulWidget {
  final List<Article> headlines;

  const WelcomePage({super.key, required this.headlines});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final images = widget.headlines
        .map((a) => a.image)
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .take(3)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The collage takes whatever is left above the copy, so the page
          // never overflows at large text sizes.
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 380),
                child: SizedBox(
                  width: double.infinity,
                  child: _Collage(images: images, animation: _controller),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE EDITION',
                  style: AppTextStyles.overline.copyWith(color: p.accent),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'The stories worth\nyour morning.',
                  style: AppTextStyles.displayXL.copyWith(color: p.ink),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'A calm, personal feed from the sections you care about. Read it anywhere — even offline.',
                  style: AppTextStyles.body.copyWith(color: p.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _Collage extends StatelessWidget {
  final List<String> images;
  final Animation<double> animation;

  const _Collage({required this.images, required this.animation});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final cardW = w * 0.62;
        final cardH = h * 0.86;

        // Back to front: left-leaning, right-leaning, centred.
        final slots = [
          (dx: -w * 0.16, dy: h * 0.02, angle: -0.14, scale: 0.9),
          (dx: w * 0.18, dy: h * 0.05, angle: 0.12, scale: 0.92),
          (dx: 0.0, dy: h * 0.0, angle: -0.02, scale: 1.0),
        ];

        return Stack(
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final t = Interval(
                    0.05 + i * 0.15,
                    0.5 + i * 0.15,
                    curve: Curves.easeOutCubic,
                  ).transform(animation.value).clamp(0.0, 1.0);
                  final slot = slots[i];
                  return Transform.translate(
                    offset: Offset(slot.dx * t, slot.dy + (1 - t) * 60),
                    child: Transform.rotate(
                      angle: slot.angle * t,
                      child: Transform.scale(
                        scale: slot.scale * (0.9 + 0.1 * t),
                        child: Opacity(opacity: t, child: child),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: cardW,
                  height: cardH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(
                          alpha: p.isLight ? 0.18 : 0.6,
                        ),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: i < images.length
                      ? CachedImage(
                          imageUrl: images[i],
                          borderRadius: AppSpacing.radiusLg,
                          height: cardH,
                          width: cardW,
                        )
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            color: p.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                          ),
                        ),
                ),
              ),
          ],
        );
      },
    );
  }
}
