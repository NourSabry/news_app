import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum FreshnessBannerVariant { offline, stale, syncing, synced }

/// The single freshness/sync banner (Part 6.4, 6.10). Never two banners at
/// once — callers pick one variant to show.
class FreshnessBanner extends StatefulWidget {
  const FreshnessBanner({
    super.key,
    required this.variant,
    required this.message,
    this.onRefresh,
    this.onDismissed,
    this.onTap,
    this.animated = true,
  });

  final FreshnessBannerVariant variant;
  final String message;
  final VoidCallback? onRefresh;
  final VoidCallback? onDismissed;

  /// Makes the whole banner tappable (e.g. tap-to-sync on a pending-changes
  /// banner) without a dedicated trailing action like [onRefresh].
  final VoidCallback? onTap;

  /// False suppresses the `syncing` variant's indeterminate progress bar —
  /// for "N changes waiting to sync" (not yet actively syncing), where an
  /// infinite animation would never let `pumpAndSettle()` return.
  final bool animated;

  @override
  State<FreshnessBanner> createState() => _FreshnessBannerState();
}

class _FreshnessBannerState extends State<FreshnessBanner> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SemanticsService.sendAnnouncement(View.of(context), widget.message, TextDirection.ltr);
    });
    if (widget.variant == FreshnessBannerVariant.synced) {
      _dismissTimer = Timer(const Duration(seconds: 2), () => widget.onDismissed?.call());
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final red = isLight ? AppColors.lightRed : AppColors.darkRed;
    final redSoft = isLight ? AppColors.lightRedSoft : AppColors.darkRedSoft;
    final warning = isLight ? AppColors.lightWarning : AppColors.darkWarning;
    final success = isLight ? AppColors.lightSuccess : AppColors.darkSuccess;
    final paperRaised = isLight ? AppColors.lightPaperRaised : AppColors.darkPaperRaised;
    final rule = isLight ? AppColors.lightRule : AppColors.darkRule;

    final (background, iconColor, icon) = switch (widget.variant) {
      FreshnessBannerVariant.offline => (redSoft, red, Icons.cloud_off_rounded),
      FreshnessBannerVariant.stale => (warning.withValues(alpha: 0.12), warning, Icons.schedule_rounded),
      FreshnessBannerVariant.syncing => (paperRaised, red, null),
      FreshnessBannerVariant.synced => (success.withValues(alpha: 0.12), success, Icons.check_circle_rounded),
    };

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 40,
        width: double.infinity,
        color: background,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, size: 16, color: iconColor),
                if (icon != null) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.message,
                    style: AppTextStyles.caption.copyWith(color: ink),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.variant == FreshnessBannerVariant.stale && widget.onRefresh != null)
                  Semantics(
                    button: true,
                    label: 'Refresh',
                    child: InkWell(
                      onTap: widget.onRefresh,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Text(
                          'Refresh',
                          style: AppTextStyles.label.copyWith(color: red, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (widget.variant == FreshnessBannerVariant.syncing && widget.animated)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: rule,
                    valueColor: AlwaysStoppedAnimation(red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
