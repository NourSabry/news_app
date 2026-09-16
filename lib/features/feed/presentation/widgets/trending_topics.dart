import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/topic_chip.dart';

class TrendingTopics extends StatelessWidget {
  final List<TrendingTopic> topics;
  final ValueChanged<TrendingTopic>? onTopicTap;

  const TrendingTopics({super.key, required this.topics, this.onTopicTap});

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();
    return _TrendingSection(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        itemCount: topics.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) => TopicChip(
          label: topics[index].label,
          isSelected: false,
          onTap: () => onTopicTap?.call(topics[index]),
        ),
      ),
    );
  }
}

class TrendingTopicsShimmer extends StatelessWidget {
  const TrendingTopicsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _TrendingSection(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: AppSpacing.screenPadding,
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, _) => const ShimmerLoading(
          width: 88,
          height: 34,
          borderRadius: AppSpacing.radiusFull,
        ),
      ),
    );
  }
}

class _TrendingSection extends StatelessWidget {
  final Widget child;

  const _TrendingSection({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.screenPadding,
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.xs),
                Text('Trending', style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(height: 34, child: child),
        ],
      ),
    );
  }
}
