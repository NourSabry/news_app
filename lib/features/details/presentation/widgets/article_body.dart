import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'content_block_view.dart';

class ArticleBody extends StatelessWidget {
  final List<ContentBlock> blocks;

  const ArticleBody({super.key, required this.blocks});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      sliver: SliverList.separated(
        itemCount: blocks.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (_, index) => ContentBlockView(block: blocks[index]),
      ),
    );
  }
}

class ArticleBodyShimmer extends StatelessWidget {
  const ArticleBodyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(height: 16),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading(height: 16),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading(height: 16, width: 220),
          SizedBox(height: AppSpacing.xl),
          ShimmerLoading(height: 200, borderRadius: AppSpacing.radiusLg),
          SizedBox(height: AppSpacing.xl),
          ShimmerLoading(height: 16),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading(height: 16, width: 260),
        ],
      ),
    );
  }
}
