import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum FreshnessBannerVariant { offline, stale, syncing, synced }

/// The single freshness/sync banner. Callers show at most one variant at a
/// time; it sits inside the gutters as a soft rounded strip.
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

  /// Makes the whole banner tappable (tap-to-sync on a pending banner).
  final VoidCallback? onTap;

  /// False suppresses the syncing variant's indeterminate bar, for a
  /// "waiting to sync" state that isn't actively uploading.
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
      SemanticsService.sendAnnouncement(
        View.of(context),
        widget.message,
        TextDirection.ltr,
      );
    });
    if (widget.variant == FreshnessBannerVariant.synced) {
      _dismissTimer = Timer(
        const Duration(seconds: 2),
        () => widget.onDismissed?.call(),
      );
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final (background, tone, icon) = switch (widget.variant) {
      FreshnessBannerVariant.offline => (
        p.accentSoft,
        p.accent,
        Icons.cloud_off_rounded,
      ),
      FreshnessBannerVariant.stale => (
        p.warning.withValues(alpha: 0.14),
        p.warning,
        Icons.schedule_rounded,
      ),
      FreshnessBannerVariant.syncing => (p.surface, p.ink, Icons.sync_rounded),
      FreshnessBannerVariant.synced => (
        p.success.withValues(alpha: 0.14),
        p.success,
        Icons.check_circle_rounded,
      ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        0,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            width: double.infinity,
            color: background,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: tone),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: AppTextStyles.caption.copyWith(
                          color: p.ink,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.variant == FreshnessBannerVariant.stale &&
                        widget.onRefresh != null)
                      Semantics(
                        button: true,
                        container: true,
                        excludeSemantics: true,
                        label: 'Refresh',
                        child: InkWell(
                          onTap: widget.onRefresh,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.sm,
                            ),
                            child: Text(
                              'Refresh',
                              style: AppTextStyles.label.copyWith(color: p.ink),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (widget.variant == FreshnessBannerVariant.syncing &&
                    widget.animated)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -AppSpacing.sm,
                    child: SizedBox(
                      height: 2,
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(p.accent),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
