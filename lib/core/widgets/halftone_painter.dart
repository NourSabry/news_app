import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The print-dot texture of a newspaper photo (Part 6.4).
enum HalftoneShape { radial, diagonal, wave }

/// A grid of dots whose radius follows [shape]. Deterministic for a given
/// [seed] so it renders identically in goldens.
class HalftonePainter extends CustomPainter {
  const HalftonePainter({
    required this.shape,
    required this.tint,
    this.density = 9,
    this.seed = 1,
    this.opacity = 1,
  });

  final HalftoneShape shape;
  final Color tint;
  final int density;
  final int seed;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = tint.withValues(alpha: opacity);
    final cell = size.shortestSide / density;
    final rows = (size.height / cell).ceil();
    final cols = (size.width / cell).ceil();
    final rng = math.Random(seed);
    final center = Offset(size.width / 2, size.height / 2);
    final maxDist = center.distance;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final cx = (col + 0.5) * cell;
        final cy = (row + 0.5) * cell;
        if (cx > size.width || cy > size.height) continue;
        final jitter = 0.85 + rng.nextDouble() * 0.3;
        final intensity = switch (shape) {
          HalftoneShape.radial =>
            (1 - (Offset(cx, cy) - center).distance / maxDist).clamp(0.0, 1.0),
          HalftoneShape.diagonal => (1 - (cx / size.width + cy / size.height) / 2).clamp(0.0, 1.0),
          HalftoneShape.wave =>
            (math.sin((cx / size.width) * math.pi * 3 + row * 0.6) + 1) / 2,
        };
        final radius = (cell / 2) * (intensity * jitter).clamp(0.0, 1.0);
        if (radius <= 0.4) continue;
        canvas.drawCircle(Offset(cx, cy), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HalftonePainter oldDelegate) {
    return shape != oldDelegate.shape ||
        tint != oldDelegate.tint ||
        density != oldDelegate.density ||
        seed != oldDelegate.seed ||
        opacity != oldDelegate.opacity;
  }
}

/// Renders a [HalftonePainter] at a fixed size. Decorative by default
/// (excluded from the semantics tree); pass [semanticLabel] when the
/// halftone stands in for a real image.
class Halftone extends StatelessWidget {
  const Halftone({
    super.key,
    required this.shape,
    this.size = 120,
    this.tint,
    this.density = 9,
    this.seed = 1,
    this.opacity = 1,
    this.semanticLabel,
  });

  final HalftoneShape shape;
  final double size;
  final Color? tint;
  final int density;
  final int seed;
  final double opacity;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final resolvedTint = tint ?? (brightness == Brightness.light ? AppColors.lightInk : AppColors.darkInk);
    final painter = CustomPaint(
      size: Size.square(size),
      painter: HalftonePainter(
        shape: shape,
        tint: resolvedTint,
        density: density,
        seed: seed,
        opacity: opacity,
      ),
    );
    if (semanticLabel == null) {
      return ExcludeSemantics(child: painter);
    }
    return Semantics(label: semanticLabel, image: true, child: painter);
  }
}
