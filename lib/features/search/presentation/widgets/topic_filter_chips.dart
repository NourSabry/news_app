import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/topic_chip.dart';

class TopicFilterChips extends StatelessWidget {
  final List<Topic> topics;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const TopicFilterChips({
    super.key,
    required this.topics,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        itemCount: topics.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) {
          if (index == 0) {
            return TopicChip(
              label: 'All',
              isSelected: selectedId == null,
              onTap: () => onSelected(null),
            );
          }
          final topic = topics[index - 1];
          final isSelected = topic.id == selectedId;
          return TopicChip(
            label: topic.name,
            isSelected: isSelected,
            onTap: () => onSelected(isSelected ? null : topic.id),
          );
        },
      ),
    );
  }
}
