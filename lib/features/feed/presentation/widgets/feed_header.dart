import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/edition_pill.dart';
import '../../../../core/widgets/icon_circle_button.dart';

/// The Home header: date, big serif title and two round actions, with a
/// trending row beneath. Collapses to a compact blurred bar on scroll.
class FeedHeader extends SliverPersistentHeaderDelegate {
  static const double collapsedHeight = 56;
  static const double _titleTextHeight = 14 + AppSpacing.xs + 44;
  static const double _titleChrome = AppSpacing.sm + AppSpacing.lg;
  static const double _trendingRow = 38 + AppSpacing.lg;

  final List<TrendingTopic> trending;
  final String? scope;
  final ValueChanged<String> onTopicTap;
  final VoidCallback onClearScope;
  final VoidCallback onSearchTap;
  final VoidCallback onSettingsTap;
  final double topPadding;

  /// The current text scale, so the expanded height grows with large text.
  final double textScale;

  FeedHeader({
    required this.trending,
    required this.scope,
    required this.onTopicTap,
    required this.onClearScope,
    required this.onSearchTap,
    required this.onSettingsTap,
    required this.topPadding,
    this.textScale = 1,
  });

  double get _expandedContentHeight =>
      _titleTextHeight * textScale +
      _titleChrome +
      (_hasTrending ? _trendingRow : AppSpacing.sm);

  bool get _hasTrending => trending.isNotEmpty || scope != null;

  @override
  double get minExtent => topPadding + collapsedHeight;

  @override
  double get maxExtent => topPadding + _expandedContentHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final p = context.palette;
    final range = (maxExtent - minExtent).clamp(1.0, double.infinity);
    final t = (shrinkOffset / range).clamp(0.0, 1.0);
    final collapsed = t > 0.85;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18 * t, sigmaY: 18 * t),
        child: Container(
          color: p.background.withValues(alpha: lerpDouble(1, 0.86, t)!),
          padding: EdgeInsets.only(top: topPadding),
          child: Stack(
            children: [
              // Expanded content keeps its full height and is clipped as it
              // scrolls under the bar, fading out on the way.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _expandedContentHeight,
                child: Opacity(
                  opacity: (1 - t * 1.6).clamp(0.0, 1.0),
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      maxHeight: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.gutter,
                              AppSpacing.sm,
                              AppSpacing.gutter,
                              0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat(
                                          'EEEE, d MMMM',
                                        ).format(DateTime.now()).toUpperCase(),
                                        style: AppTextStyles.overline.copyWith(
                                          color: p.inkMuted,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'The Edition',
                                        style: AppTextStyles.displayXL.copyWith(
                                          color: p.ink,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                IconCircleButton(
                                  icon: Icons.search_rounded,
                                  label: 'Search',
                                  onTap: onSearchTap,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                IconCircleButton(
                                  icon: Icons.tune_rounded,
                                  label: 'Settings',
                                  onTap: onSettingsTap,
                                ),
                              ],
                            ),
                          ),
                          if (_hasTrending) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _TrendingRow(
                              trending: trending,
                              scope: scope,
                              onTopicTap: onTopicTap,
                              onClearScope: onClearScope,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Compact bar.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: collapsedHeight,
                child: IgnorePointer(
                  ignoring: !collapsed,
                  child: AnimatedOpacity(
                    duration: AppMotion.scaled(context, AppMotion.micro),
                    opacity: collapsed ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.gutter,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              scope ?? 'The Edition',
                              style: AppTextStyles.headlineS.copyWith(
                                color: p.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconCircleButton(
                            icon: Icons.search_rounded,
                            label: 'Search',
                            onTap: onSearchTap,
                            size: 38,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          IconCircleButton(
                            icon: Icons.tune_rounded,
                            label: 'Settings',
                            onTap: onSettingsTap,
                            size: 38,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant FeedHeader oldDelegate) {
    return oldDelegate.trending != trending ||
        oldDelegate.scope != scope ||
        oldDelegate.topPadding != topPadding ||
        oldDelegate.textScale != textScale;
  }
}

class _TrendingRow extends StatelessWidget {
  final List<TrendingTopic> trending;
  final String? scope;
  final ValueChanged<String> onTopicTap;
  final VoidCallback onClearScope;

  const _TrendingRow({
    required this.trending,
    required this.scope,
    required this.onTopicTap,
    required this.onClearScope,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        children: [
          if (scope != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: EditionPill(
                label: scope!,
                variant: EditionPillVariant.filled,
                leadingIcon: Icons.trending_up_rounded,
                onTap: onClearScope,
                onRemove: onClearScope,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: p.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'TRENDING',
                    style: AppTextStyles.overline.copyWith(color: p.inkMuted),
                  ),
                ],
              ),
            ),
          for (final topic in trending)
            if (topic.label != scope)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: EditionPill(
                  label: topic.label,
                  onTap: () => onTopicTap(topic.label),
                ),
              ),
        ],
      ),
    );
  }
}
