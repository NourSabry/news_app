import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// The floating "N new · headline…" pill shown when a refresh found stories
/// the reader hasn't seen. Tapping it inserts them at the top.
class NewStoriesBanner extends StatefulWidget {
  final int count;
  final String? firstHeadline;
  final VoidCallback onTap;

  const NewStoriesBanner({
    super.key,
    required this.count,
    this.firstHeadline,
    required this.onTap,
  });

  @override
  State<NewStoriesBanner> createState() => _NewStoriesBannerState();
}

class _NewStoriesBannerState extends State<NewStoriesBanner> {
  @override
  void didUpdateWidget(NewStoriesBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count == 0 && widget.count > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SemanticsService.sendAnnouncement(
          View.of(context),
          _label,
          TextDirection.ltr,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isVisible = widget.count > 0;

    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: AppMotion.scaled(context, AppMotion.transition),
        curve: AppMotion.curveSettle,
        offset: isVisible ? Offset.zero : const Offset(0, -2),
        child: AnimatedOpacity(
          duration: AppMotion.scaled(context, AppMotion.transition),
          opacity: isVisible ? 1 : 0,
          child: Semantics(
            button: true,
            container: true,
            excludeSemantics: true,
            label: _label,
            child: Material(
              color: p.ink,
              elevation: 0,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm + 2,
                    AppSpacing.lg,
                    AppSpacing.sm + 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 16,
                        color: p.background,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Text(
                          _label,
                          style: AppTextStyles.label.copyWith(
                            color: p.background,
                          ),
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
    final countLabel = count == 1 ? '1 new story' : '$count new stories';
    if (firstHeadline == null || firstHeadline.isEmpty) return countLabel;
    return '$countLabel · $firstHeadline';
  }
}
