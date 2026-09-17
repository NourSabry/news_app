import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'section_tile.dart';

/// Screen 2 — pick sections (Part 6.5).
class SectionsPage extends StatelessWidget {
  final List<Topic> topics;
  final Set<String> selectedIds;
  final Map<String, int> topicCounts;
  final ValueChanged<String> onToggle;

  const SectionsPage({
    super.key,
    required this.topics,
    required this.selectedIds,
    required this.topicCounts,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Text('Which sections do you read?', style: AppTextStyles.displayL.copyWith(color: ink)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pick at least one. You can change this any time.',
            style: AppTextStyles.body.copyWith(color: inkMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.15,
              ),
              itemCount: topics.length,
              itemBuilder: (_, index) {
                final topic = topics[index];
                return SectionTile(
                  topic: topic,
                  isSelected: selectedIds.contains(topic.id),
                  articleCount: topicCounts[topic.id],
                  onTap: () => onToggle(topic.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
