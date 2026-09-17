import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/hairline.dart';

/// Screen 1 — the wordmark assembles, then real headlines rise into a
/// front page (Part 6.5).
class MastheadPage extends StatefulWidget {
  final List<Article> headlines;
  final List<Topic> topics;

  const MastheadPage({super.key, required this.headlines, required this.topics});

  @override
  State<MastheadPage> createState() => _MastheadPageState();
}

class _MastheadPageState extends State<MastheadPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;

    final wordmarkFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    const ruleReveal = Interval(0.3, 0.5, curve: Curves.easeOutCubic);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          FadeTransition(
            opacity: wordmarkFade,
            child: Text('The Edition', style: AppTextStyles.displayL.copyWith(color: ink)),
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: ruleReveal.transform(_controller.value).clamp(0.0, 1.0),
                child: child,
              ),
            ),
            child: Hairline(color: brightness == Brightness.light ? AppColors.lightRuleStrong : AppColors.darkRuleStrong),
          ),
          const SizedBox(height: AppSpacing.md),
          FadeTransition(
            opacity: CurvedAnimation(parent: _controller, curve: const Interval(0.45, 0.6)),
            child: Text(
              DateFormat('EEEE, d MMMM y').format(DateTime.now()).toUpperCase(),
              style: AppTextStyles.overline.copyWith(color: inkMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          for (var i = 0; i < widget.headlines.length; i++) ...[
            _StaggeredHeadline(
              article: widget.headlines[i],
              topicName: widget.topics.nameFor(widget.headlines[i].topicId),
              animation: _controller,
              interval: Interval(0.5 + i * 0.12, (0.72 + i * 0.12).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
            ),
            if (i < widget.headlines.length - 1) const Hairline(),
          ],
          const SizedBox(height: AppSpacing.xxl),
          FadeTransition(
            opacity: CurvedAnimation(parent: _controller, curve: const Interval(0.85, 1.0)),
            child: Text(
              'Your news, set in type.',
              style: AppTextStyles.body.copyWith(color: inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggeredHeadline extends StatelessWidget {
  final Article article;
  final String topicName;
  final Animation<double> animation;
  final Interval interval;

  const _StaggeredHeadline({
    required this.article,
    required this.topicName,
    required this.animation,
    required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final ink = brightness == Brightness.light ? AppColors.lightInk : AppColors.darkInk;
    final tint = AppColors.sectionTint(topicName, brightness);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = interval.transform(animation.value).clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, (1 - t) * 16), child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (topicName.isNotEmpty) ...[
              Text(topicName.toUpperCase(), style: AppTextStyles.overline.copyWith(color: tint)),
              const SizedBox(height: AppSpacing.xs),
            ],
            Text(article.title, style: AppTextStyles.headlineS.copyWith(color: ink), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
