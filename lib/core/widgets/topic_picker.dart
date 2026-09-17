import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class TopicPicker extends StatelessWidget {
  final List<Topic> topics;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final bool shrinkWrap;

  const TopicPicker({
    super.key,
    required this.topics,
    required this.selectedIds,
    required this.onToggle,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.2,
      ),
      itemCount: topics.length,
      itemBuilder: (_, index) {
        final topic = topics[index];
        return _TopicTile(
          topic: topic,
          isSelected: selectedIds.contains(topic.id),
          onTap: () => onToggle(topic.id),
        );
      },
    );
  }
}

class _TopicTile extends StatelessWidget {
  final Topic topic;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopicTile({required this.topic, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final card = isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final foreground = isSelected ? AppColors.white : theme.colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? accent : card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: isSelected ? null : Border.all(color: theme.dividerColor, width: 0.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(
              _iconFor(topic.icon),
              size: 24,
              color: isSelected ? AppColors.white : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                topic.name,
                style: theme.textTheme.titleMedium?.copyWith(color: foreground),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.white),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String iconName) {
    return switch (iconName) {
      'devices' => Icons.devices_rounded,
      'business' => Icons.business_rounded,
      'sports_soccer' => Icons.sports_soccer_rounded,
      'science' => Icons.science_rounded,
      'health_and_safety' => Icons.health_and_safety_rounded,
      'palette' => Icons.palette_rounded,
      _ => Icons.tag_rounded,
    };
  }
}
