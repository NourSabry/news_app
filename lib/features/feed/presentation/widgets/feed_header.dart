import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../outbox/presentation/widgets/network_debug_menu.dart';

class FeedHeader extends StatelessWidget {
  final DateTime? lastSyncedAt;
  final VoidCallback? onSettingsTap;

  const FeedHeader({super.key, this.lastSyncedAt, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(now).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(_greetingFor(now.hour), style: theme.textTheme.headlineLarge),
                if (lastSyncedAt != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(_syncLabel(lastSyncedAt!, now), style: theme.textTheme.labelMedium),
                ],
              ],
            ),
          ),
          if (kDebugMode) const NetworkDebugMenu(),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: onSettingsTap,
          ),
        ],
      ),
    );
  }

  String _greetingFor(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _syncLabel(DateTime time, DateTime now) {
    return 'Updated ${TimeFormatter.relative(time, now: now).toLowerCase()}';
  }
}
