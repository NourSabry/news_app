import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ink_button.dart';

/// Closes the feed: which sections it's built from, and a way to change them.
class SectionsFooter extends StatelessWidget {
  final int count;
  final VoidCallback onEdit;

  const SectionsFooter({super.key, required this.count, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.xxl,
      ),
      child: Column(
        children: [
          Text(
            count == 0 ? 'Built from all sections' : 'Built from $_label',
            style: AppTextStyles.caption.copyWith(color: p.inkFaint),
          ),
          const SizedBox(height: AppSpacing.xs),
          InkButton(
            label: 'Edit sections',
            onPressed: onEdit,
            variant: InkButtonVariant.text,
            expand: false,
          ),
        ],
      ),
    );
  }

  String get _label => '$count ${count == 1 ? 'section' : 'sections'}';
}
