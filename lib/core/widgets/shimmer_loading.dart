import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Duration period;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppSpacing.radiusSm,
    this.period = const Duration(milliseconds: 1600),
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Shimmer.fromColors(
      period: period,
      baseColor: p.surface,
      highlightColor: p.surfaceHigh,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for a compact card (thumbnail right).
class ArticleCardShimmer extends StatelessWidget {
  const ArticleCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.gutter,
        vertical: AppSpacing.md,
      ),
      child: CompactCardSkeleton(),
    );
  }
}

class FeedShimmer extends StatelessWidget {
  final int itemCount;

  const FeedShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (_, _) => const ArticleCardShimmer(),
    );
  }
}

/// Matches the lead card so the real card swaps in without a layout jump.
class LeadCardSkeleton extends StatelessWidget {
  const LeadCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: ShimmerLoading(
            height: double.infinity,
            borderRadius: AppSpacing.radiusLg,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        ShimmerLoading(height: 14, width: 90),
      ],
    );
  }
}

/// Matches the standard card (full-width image above text).
class StandardCardSkeleton extends StatelessWidget {
  const StandardCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: ShimmerLoading(
            height: double.infinity,
            borderRadius: AppSpacing.radiusMd,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        ShimmerLoading(height: 11, width: 70),
        SizedBox(height: AppSpacing.sm),
        ShimmerLoading(height: 20, width: double.infinity),
        SizedBox(height: AppSpacing.xs),
        ShimmerLoading(height: 20, width: 200),
        SizedBox(height: AppSpacing.sm),
        ShimmerLoading(height: 12, width: 140),
      ],
    );
  }
}

/// Matches the compact card (text left, thumbnail right).
class CompactCardSkeleton extends StatelessWidget {
  const CompactCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoading(height: 11, width: 70),
              SizedBox(height: AppSpacing.sm),
              ShimmerLoading(height: 18, width: double.infinity),
              SizedBox(height: AppSpacing.xs),
              ShimmerLoading(height: 18, width: 160),
              SizedBox(height: AppSpacing.sm),
              ShimmerLoading(height: 12, width: 120),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        ShimmerLoading(
          width: 96,
          height: 96,
          borderRadius: AppSpacing.radiusSm,
        ),
      ],
    );
  }
}

/// A skeleton feed matching the real lead → standard → compact rhythm.
class HomeFeedSkeleton extends StatelessWidget {
  final int compactCount;

  const HomeFeedSkeleton({super.key, this.compactCount = 2});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LeadCardSkeleton(),
          const SizedBox(height: AppSpacing.xxxl),
          const StandardCardSkeleton(),
          for (var i = 0; i < compactCount; i++) ...[
            const SizedBox(height: AppSpacing.xxxl),
            const CompactCardSkeleton(),
          ],
        ],
      ),
    );
  }
}
