import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/double_rule.dart';
import '../../../../core/widgets/hairline.dart';

/// The Home header (Part 6.6): masthead block that collapses into a
/// sticky bar on scroll. Carries the only other use of the double rule
/// besides the nav bar.
class EditionMastheadHeader extends SliverPersistentHeaderDelegate {
  static const double expandedHeight = 144;
  static const double collapsedHeight = 56;

  final List<TrendingTopic> trending;
  final String? scope;
  final ValueChanged<String> onTopicTap;
  final VoidCallback onClearScope;
  final VoidCallback onSearchTap;
  final VoidCallback onSettingsTap;

  EditionMastheadHeader({
    required this.trending,
    required this.scope,
    required this.onTopicTap,
    required this.onClearScope,
    required this.onSearchTap,
    required this.onSettingsTap,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final paperRaised = isLight ? AppColors.lightPaperRaised : AppColors.darkPaperRaised;

    return Container(
      color: paperRaised,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(opacity: 1 - progress, child: _ExpandedMasthead(
            trending: trending,
            scope: scope,
            onTopicTap: onTopicTap,
            onClearScope: onClearScope,
            onSearchTap: onSearchTap,
            onSettingsTap: onSettingsTap,
          )),
          Opacity(opacity: progress, child: _CollapsedBar(onSearchTap: onSearchTap, onSettingsTap: onSettingsTap)),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant EditionMastheadHeader oldDelegate) {
    return oldDelegate.trending != trending ||
        oldDelegate.scope != scope ||
        oldDelegate.onTopicTap != onTopicTap;
  }
}

class _ExpandedMasthead extends StatelessWidget {
  final List<TrendingTopic> trending;
  final String? scope;
  final ValueChanged<String> onTopicTap;
  final VoidCallback onClearScope;
  final VoidCallback onSearchTap;
  final VoidCallback onSettingsTap;

  const _ExpandedMasthead({
    required this.trending,
    required this.scope,
    required this.onTopicTap,
    required this.onClearScope,
    required this.onSearchTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM y').format(DateTime.now()).toUpperCase(),
                      style: AppTextStyles.overline.copyWith(color: inkMuted),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('The Edition', style: AppTextStyles.masthead.copyWith(color: ink)),
                  ],
                ),
              ),
              Semantics(
                button: true,
                container: true,
                excludeSemantics: true,
                label: 'Search',
                child: IconButton(icon: const Icon(Icons.search_rounded), onPressed: onSearchTap),
              ),
              Semantics(
                button: true,
                container: true,
                excludeSemantics: true,
                label: 'Settings',
                child: IconButton(icon: const Icon(Icons.settings_outlined), onPressed: onSettingsTap),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: DoubleRule(),
        ),
        SizedBox(
          height: 34,
          child: scope != null
              ? _ScopeRow(scope: scope!, onClear: onClearScope)
              : _TickerRow(topics: trending, onTopicTap: onTopicTap),
        ),
        const Hairline(),
      ],
    );
  }
}

class _CollapsedBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onSettingsTap;

  const _CollapsedBar({required this.onSearchTap, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final ink = brightness == Brightness.light ? AppColors.lightInk : AppColors.darkInk;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          // 48×48 tap targets (G6/T4, androidTapTargetGuideline) — was
          // 36×36, tightened only for the the redesign overflow fix;
          // collapsedHeight grew to fit it back.
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Row(
              children: [
                Text('The Edition', style: AppTextStyles.headlineS.copyWith(color: ink)),
                const Spacer(),
                Semantics(
                  button: true,
                  container: true,
                  excludeSemantics: true,
                  label: 'Search',
                  child: IconButton(
                    constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.search_rounded),
                    onPressed: onSearchTap,
                  ),
                ),
                Semantics(
                  button: true,
                  container: true,
                  excludeSemantics: true,
                  label: 'Settings',
                  child: IconButton(
                    constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: onSettingsTap,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Hairline(),
      ],
    );
  }
}

class _TickerRow extends StatelessWidget {
  final List<TrendingTopic> topics;
  final ValueChanged<String> onTopicTap;

  const _TickerRow({required this.topics, required this.onTopicTap});

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;
    final red = isLight ? AppColors.lightRed : AppColors.darkRed;

    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      children: [
        _PulsingDot(color: red),
        const SizedBox(width: AppSpacing.sm),
        Text('TRENDING', style: AppTextStyles.overline.copyWith(color: inkMuted)),
        const SizedBox(width: AppSpacing.md),
        for (var i = 0; i < topics.length; i++) ...[
          if (i > 0) ...[
            Text('·', style: AppTextStyles.label.copyWith(color: inkMuted)),
            const SizedBox(width: AppSpacing.md),
          ],
          Semantics(
            button: true,
            container: true,
            excludeSemantics: true,
            label: 'Trending: ${topics[i].label}',
            child: InkWell(
              onTap: () => onTopicTap(topics[i].label),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(topics[i].label, style: AppTextStyles.label.copyWith(color: ink)),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ],
    );
  }
}

class _ScopeRow extends StatelessWidget {
  final String scope;
  final VoidCallback onClear;

  const _ScopeRow({required this.scope, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final red = isLight ? AppColors.lightRed : AppColors.darkRed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Row(
        children: [
          Icon(Icons.trending_up_rounded, size: 16, color: red),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Trending · $scope',
              style: AppTextStyles.label.copyWith(color: ink, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Semantics(
            button: true,
            container: true,
            excludeSemantics: true,
            label: 'Clear trending filter',
            child: InkWell(
              onTap: onClear,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Icon(Icons.close_rounded, size: 18, color: ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  // A bounded number of pulses, not an unbounded repeat() — an infinite
  // ticker never lets pumpAndSettle() (used throughout the widget tests)
  // settle.
  static const _pulses = 3;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900 * _pulses),
  )..forward();
  late final Animation<double> _opacity = TweenSequence([
    for (var i = 0; i < _pulses; i++) ...[
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 1),
    ],
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _opacity,
        child: Container(width: 6, height: 6, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
      ),
    );
  }
}
