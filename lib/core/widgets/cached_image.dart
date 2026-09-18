import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../di/service_locator.dart';
import '../theme/app_spacing.dart';
import 'shimmer_loading.dart';

class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  /// A caption to read for this image. Leave null when the image is
  /// decorative inside content that already carries its own label.
  final String? semanticLabel;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = AppSpacing.radiusMd,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final content = imageUrl == null || imageUrl!.isEmpty
        ? _placeholder(context)
        : ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: CachedNetworkImage(
              imageUrl: imageUrl!,
              cacheManager: ServiceLocator.instance.get<BaseCacheManager>(),
              width: width,
              height: height,
              fit: fit,
              placeholder: (_, _) => ShimmerLoading(
                height: height ?? 200,
                width: width ?? double.infinity,
                borderRadius: borderRadius,
              ),
              errorWidget: (_, _, _) => _placeholder(context),
            ),
          );

    if (semanticLabel != null) {
      return Semantics(
        image: true,
        label: semanticLabel,
        child: ExcludeSemantics(child: content),
      );
    }
    return ExcludeSemantics(child: content);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
