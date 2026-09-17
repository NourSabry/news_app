import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/halftone_painter.dart';

/// The details hero image: a halftone placeholder that resolves into the
/// real photo on load (Part 6.4, 6.9), with floating back/share buttons.
class DetailsHero extends StatelessWidget {
  final String? imageUrl;
  final String heroTag;
  final VoidCallback onBack;
  final VoidCallback onShare;

  const DetailsHero({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    required this.onBack,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(tag: heroTag, child: _Image(imageUrl: imageUrl)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(icon: Icons.arrow_back_rounded, label: 'Back', onTap: onBack),
                  _CircleButton(icon: Icons.ios_share_rounded, label: 'Share', onTap: onShare),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Image extends StatelessWidget {
  final String? imageUrl;

  const _Image({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final tint = brightness == Brightness.light ? AppColors.lightInk : AppColors.darkInk;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return ExcludeSemantics(
        child: ColoredBox(
          color: brightness == Brightness.light ? AppColors.lightPaperRaised : AppColors.darkPaperRaised,
          child: Center(child: Halftone(shape: HalftoneShape.radial, size: 120, tint: tint)),
        ),
      );
    }

    // Decorative (G6) — the headline right below already carries the
    // article title as its own text node.
    return ExcludeSemantics(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        cacheManager: ServiceLocator.instance.get<BaseCacheManager>(),
        fit: BoxFit.cover,
        fadeInDuration: AppMotion.transition,
        placeholder: (context, _) => ColoredBox(
          color: brightness == Brightness.light ? AppColors.lightPaperRaised : AppColors.darkPaperRaised,
          child: Center(child: Halftone(shape: HalftoneShape.radial, size: 120, tint: tint)),
        ),
        errorWidget: (context, _, _) => ColoredBox(
          color: brightness == Brightness.light ? AppColors.lightPaperRaised : AppColors.darkPaperRaised,
          child: Center(child: Halftone(shape: HalftoneShape.radial, size: 120, tint: tint)),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      label: label,
      child: Material(
        color: AppColors.lightInk.withValues(alpha: 0.55),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            // androidTapTargetGuideline wants 48×48 (G6/T4).
            width: 48,
            height: 48,
            child: Center(child: Icon(icon, size: 20, color: AppColors.white)),
          ),
        ),
      ),
    );
  }
}
