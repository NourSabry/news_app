import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A section row: tinted dot, name, and a check that fills when selected.
class TopicToggleRow extends StatelessWidget {
  final Topic topic;
  final bool isSelected;
  final VoidCallback onTap;

  const TopicToggleRow({
    super.key,
    required this.topic,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tint = p.sectionTint(topic.name);

    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      selected: isSelected,
      label: topic.name,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  topic.name,
                  style: AppTextStyles.body.copyWith(color: p.ink),
                ),
              ),
              AnimatedContainer(
                duration: AppMotion.scaled(context, AppMotion.micro),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? p.ink : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? p.ink : p.inkFaint,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check_rounded, size: 15, color: p.background)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
