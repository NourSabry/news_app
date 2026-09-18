import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'section_tile.dart';

/// Screen 2 — pick sections.
class SectionsPage extends StatelessWidget {
  final List<Topic> topics;
  final Set<String> selectedIds;
  final Map<String, int> topicCounts;
  final Map<String, String> topicCovers;
  final ValueChanged<String> onToggle;

  const SectionsPage({
    super.key,
    required this.topics,
    required this.selectedIds,
    required this.topicCounts,
    required this.topicCovers,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.xxxl,
            AppSpacing.gutter,
            AppSpacing.xl,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What do you\nread?',
                  style: AppTextStyles.displayXL.copyWith(color: p.ink),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Pick at least one section. You can change this any time.',
                  style: AppTextStyles.body.copyWith(color: p.inkMuted),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.05,
            ),
            delegate: SliverChildBuilderDelegate((_, index) {
              final topic = topics[index];
              return SectionTile(
                topic: topic,
                isSelected: selectedIds.contains(topic.id),
                articleCount: topicCounts[topic.id],
                coverUrl: topicCovers[topic.id],
                onTap: () => onToggle(topic.id),
              );
            }, childCount: topics.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      ],
    );
  }
}
