import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// The floating "N new · headline…" pill (Part 6.6): ink fill, paper text,
/// red dot.
class NewStoriesBanner extends StatefulWidget {
  final int count;
  final String? firstHeadline;
  final VoidCallback onTap;

  const NewStoriesBanner({super.key, required this.count, this.firstHeadline, required this.onTap});

  @override
  State<NewStoriesBanner> createState() => _NewStoriesBannerState();
}

class _NewStoriesBannerState extends State<NewStoriesBanner> {
  @override
  void didUpdateWidget(NewStoriesBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Announce the moment it appears (G6) — a screen-reader user browsing
    // elsewhere on the page would otherwise never discover a silent pill.
    if (oldWidget.count == 0 && widget.count > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SemanticsService.sendAnnouncement(View.of(context), _label, TextDirection.ltr);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.count;
    final onTap = widget.onTap;
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final paper = isLight ? AppColors.lightPaper : AppColors.darkPaper;
    final red = isLight ? AppColors.lightRed : AppColors.darkRed;
    final isVisible = count > 0;

    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: AppMotion.scaled(context, AppMotion.transition),
        curve: AppMotion.curveIn,
        offset: isVisible ? Offset.zero : const Offset(0, -2),
        child: AnimatedOpacity(
          duration: AppMotion.scaled(context, AppMotion.transition),
          opacity: isVisible ? 1 : 0,
          child: Semantics(
            button: true,
            label: _label,
            child: Material(
              color: ink,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: red, shape: BoxShape.circle)),
                      const SizedBox(width: AppSpacing.sm),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Text(
                          _label,
                          style: AppTextStyles.label.copyWith(color: paper, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _label {
    final count = widget.count;
    final firstHeadline = widget.firstHeadline;
    final countLabel = count == 1 ? '1 new' : '$count new';
    if (firstHeadline == null || firstHeadline.isEmpty) return countLabel;
    return '$countLabel · $firstHeadline';
  }
}
