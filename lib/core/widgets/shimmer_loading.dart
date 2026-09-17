import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  /// Slow (1.6 s) shimmer from `rule` toward `paperRaised` (Part 6.6).
  final Duration period;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppSpacing.radiusImage,
    this.period = const Duration(milliseconds: 1600),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      period: period,
      baseColor: isDark ? AppColors.darkRule : AppColors.lightRule,
      highlightColor: isDark ? AppColors.darkPaperRaised : AppColors.lightPaperRaised,
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

class ArticleCardShimmer extends StatelessWidget {
  const ArticleCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(height: 200, borderRadius: AppSpacing.radiusLg),
          SizedBox(height: AppSpacing.md),
          ShimmerLoading(height: 20, width: 250),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading(height: 16, width: 180),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              ShimmerLoading(height: 14, width: 80),
              SizedBox(width: AppSpacing.md),
              ShimmerLoading(height: 14, width: 60),
            ],
          ),
        ],
      ),
    );
  }
}

class FeedShimmer extends StatelessWidget {
  final int itemCount;

  const FeedShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, _) => const ArticleCardShimmer(),
    );
  }
}

/// Matches [ArticleCardVariant.lead] exactly, so the real card swaps in
/// with no layout jump (Part 6.6).
class LeadCardSkeleton extends StatelessWidget {
  const LeadCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(aspectRatio: 4 / 3, child: ShimmerLoading(height: double.infinity)),
        SizedBox(height: AppSpacing.md),
        ShimmerLoading(height: 14, width: 90),
        SizedBox(height: AppSpacing.sm),
        ShimmerLoading(height: 16, width: 120),
      ],
    );
  }
}

/// Matches [ArticleCardVariant.standard].
class StandardCardSkeleton extends StatelessWidget {
  const StandardCardSkeleton({super.key});

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
              ShimmerLoading(height: 18, width: 180),
              SizedBox(height: AppSpacing.sm),
              ShimmerLoading(height: 14, width: 140),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.md),
        ShimmerLoading(width: 96, height: 96),
      ],
    );
  }
}

/// A skeleton feed matching the real Lead → Standard×N pattern.
class HomeFeedSkeleton extends StatelessWidget {
  final int standardCount;

  const HomeFeedSkeleton({super.key, this.standardCount = 3});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LeadCardSkeleton(),
          for (var i = 0; i < standardCount; i++) ...[
            const SizedBox(height: AppSpacing.lg),
            const StandardCardSkeleton(),
          ],
        ],
      ),
    );
  }
}
