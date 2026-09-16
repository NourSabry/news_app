import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../connectivity/connectivity_cubit.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class OfflineBanner extends StatelessWidget {
  final int pendingCount;
  final bool isSyncing;
  final VoidCallback? onSync;

  const OfflineBanner({
    super.key,
    this.pendingCount = 0,
    this.isSyncing = false,
    this.onSync,
  });

  bool get _hasPending => pendingCount > 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      builder: (context, status) {
        final offline = status == ConnectivityStatus.disconnected;
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: offline || _hasPending || isSyncing
              ? _buildStrip(context, offline)
              : const SizedBox(width: double.infinity),
        );
      },
    );
  }

  Widget _buildStrip(BuildContext context, bool offline) {
    final theme = Theme.of(context);
    final foreground = offline ? AppColors.black : theme.colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      color: offline ? AppColors.warning : theme.colorScheme.primary.withValues(alpha: 0.12),
      child: Row(
        children: [
          _buildLeading(offline, foreground),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _message(offline),
              style: theme.textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_hasPending)
            _PendingChip(
              count: pendingCount,
              color: foreground,
              onTap: offline || isSyncing ? null : onSync,
            ),
        ],
      ),
    );
  }

  Widget _buildLeading(bool offline, Color color) {
    if (offline) return Icon(Icons.wifi_off_rounded, size: 16, color: color);
    if (isSyncing) {
      return SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    return Icon(Icons.cloud_upload_outlined, size: 16, color: color);
  }

  String _message(bool offline) {
    if (offline) return 'You are offline';
    if (isSyncing) return 'Syncing…';
    return 'Changes waiting to sync';
  }
}

class _PendingChip extends StatelessWidget {
  final int count;
  final Color color;
  final VoidCallback? onTap;

  const _PendingChip({required this.count, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          '$count pending ${count == 1 ? 'change' : 'changes'}',
          style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
