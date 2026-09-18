import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/edition_pill.dart';

/// Explore before a query: recent searches as pills, then a photo grid of
/// sections to browse.
class ExploreLanding extends StatelessWidget {
  final List<String> queries;
  final List<Topic> topics;
  final Map<String, String> covers;
  final ValueChanged<String> onQueryTap;
  final VoidCallback onClear;
  final ValueChanged<Topic> onTopicTap;

  const ExploreLanding({
    super.key,
    required this.queries,
    required this.topics,
    required this.covers,
    required this.onQueryTap,
    required this.onClear,
    required this.onTopicTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (queries.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.lg,
                AppSpacing.gutter,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent',
                      style: AppTextStyles.headlineS.copyWith(color: p.ink),
                    ),
                  ),
                  Semantics(
                    button: true,
                    container: true,
                    excludeSemantics: true,
                    label: 'Clear recent searches',
                    child: InkWell(
                      onTap: onClear,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Text(
                          'Clear',
                          style: AppTextStyles.label.copyWith(
                            color: p.inkMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final query in queries)
                    EditionPill(
                      label: query,
                      leadingIcon: Icons.history_rounded,
                      onTap: () => onQueryTap(query),
                    ),
                ],
              ),
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.xxl,
              AppSpacing.gutter,
              AppSpacing.lg,
            ),
            child: Text(
              'Browse sections',
              style: AppTextStyles.headlineS.copyWith(color: p.ink),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            0,
            AppSpacing.gutter,
            AppSpacing.dockClearance,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.25,
            ),
            delegate: SliverChildBuilderDelegate((_, index) {
              final topic = topics[index];
              return _SectionCover(
                topic: topic,
                imageUrl: covers[topic.id],
                onTap: () => onTopicTap(topic),
              );
            }, childCount: topics.length),
          ),
        ),
      ],
    );
  }
}

class _SectionCover extends StatelessWidget {
  final Topic topic;
  final String? imageUrl;
  final VoidCallback onTap;

  const _SectionCover({
    required this.topic,
    required this.imageUrl,
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
      label: 'Browse ${topic.name}',
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl != null)
                CachedImage(imageUrl: imageUrl, borderRadius: 0)
              else
                ColoredBox(
                  color: Color.alphaBlend(
                    tint.withValues(alpha: 0.3),
                    p.surface,
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.black.withValues(alpha: 0.1),
                      AppColors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Text(
                  topic.name,
                  style: AppTextStyles.headlineS.copyWith(
                    color: AppColors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
