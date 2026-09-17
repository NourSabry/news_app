import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A section row with a tinted left rule (Part 6.12).
class TopicToggleRow extends StatelessWidget {
  final Topic topic;
  final bool isSelected;
  final VoidCallback onTap;

  const TopicToggleRow({super.key, required this.topic, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkFaint = isLight ? AppColors.lightInkFaint : AppColors.darkInkFaint;
    final tint = AppColors.sectionTint(topic.name, brightness);

    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      selected: isSelected,
      label: topic.name,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(border: Border(left: BorderSide(color: isSelected ? tint : inkFaint, width: 4))),
          child: Row(
            children: [
              Expanded(child: Text(topic.name, style: AppTextStyles.body.copyWith(color: ink))),
              if (isSelected) Icon(Icons.check_rounded, size: 20, color: tint),
            ],
          ),
        ),
      ),
    );
  }
}
