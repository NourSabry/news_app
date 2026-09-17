import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/hairline.dart';

/// The no-query Explore state (Part 6.7): recent searches, then browse by
/// section.
class ExploreLanding extends StatelessWidget {
  final List<String> queries;
  final List<Topic> topics;
  final ValueChanged<String> onQueryTap;
  final VoidCallback onClear;
  final ValueChanged<Topic> onTopicTap;

  const ExploreLanding({
    super.key,
    required this.queries,
    required this.topics,
    required this.onQueryTap,
    required this.onClear,
    required this.onTopicTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        if (queries.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, AppSpacing.sm),
            child: Row(
              children: [
                Expanded(child: Text('RECENT SEARCHES', style: AppTextStyles.overline.copyWith(color: inkMuted))),
                InkWell(
                  onTap: onClear,
                  child: Text('Clear', style: AppTextStyles.label.copyWith(color: ink, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          for (final query in queries) ...[
            _Row(
              label: query,
              style: AppTextStyles.body.copyWith(color: ink),
              onTap: () => onQueryTap(query),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter), child: Hairline()),
          ],
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.xxl, AppSpacing.gutter, AppSpacing.sm),
          child: Text('BROWSE SECTIONS', style: AppTextStyles.overline.copyWith(color: inkMuted)),
        ),
        for (final topic in topics) _SectionRow(topic: topic, onTap: () => onTopicTap(topic)),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final TextStyle style;
  final VoidCallback onTap;

  const _Row({required this.label, required this.style, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.md),
        child: Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  final Topic topic;
  final VoidCallback onTap;

  const _SectionRow({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final ink = brightness == Brightness.light ? AppColors.lightInk : AppColors.darkInk;
    final tint = AppColors.sectionTint(topic.name, brightness);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.xs),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: tint, width: 4))),
        child: Text(topic.name, style: AppTextStyles.headlineS.copyWith(color: ink)),
      ),
    );
  }
}
