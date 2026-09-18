import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/icon_circle_button.dart';

/// The article hero: an edge-to-edge photo with rounded bottom corners and
/// glass back/share buttons floating over it.
class DetailsHero extends StatelessWidget {
  static const double height = 380;

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
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(AppSpacing.radiusXl),
            ),
            child: Hero(
              tag: heroTag,
              child: _Image(imageUrl: imageUrl),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconCircleButton(
                    icon: Icons.arrow_back_rounded,
                    label: 'Back',
                    onTap: onBack,
                    glass: true,
                    size: 48,
                  ),
                  IconCircleButton(
                    icon: Icons.ios_share_rounded,
                    label: 'Share',
                    onTap: onShare,
                    glass: true,
                    size: 48,
                  ),
                ],
              ),
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
    final p = context.palette;
    final fallback = ColoredBox(
      color: p.surface,
      child: Center(
        child: Icon(Icons.image_outlined, size: 40, color: p.inkFaint),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return ExcludeSemantics(child: fallback);
    }

    // Decorative — the headline below carries the title.
    return ExcludeSemantics(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        cacheManager: ServiceLocator.instance.get<BaseCacheManager>(),
        fit: BoxFit.cover,
        fadeInDuration: AppMotion.transition,
        placeholder: (_, _) => ColoredBox(color: p.surface),
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}
