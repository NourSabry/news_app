import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppSpacing.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkShimmerBase : AppColors.lightShimmerBase,
      highlightColor: isDark ? AppColors.darkShimmerHighlight : AppColors.lightShimmerHighlight,
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
