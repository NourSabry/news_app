import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/snack_bar.dart';
import '../../../core/widgets/shimmer_loading.dart';
import 'cubit/settings_cubit.dart';
import 'widgets/developer_section.dart';
import 'widgets/settings_section.dart';
import 'widgets/sync_tile.dart';
import 'widgets/theme_mode_selector.dart';
import 'widgets/topic_toggle_row.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _version = '1.0.0 (1)';

  SettingsCubit get _cubit => context.read<SettingsCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.loadTopics();
  }

  Future<bool> _confirm(String title, String message, String action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(action)),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _clearCache() async {
    final confirmed = await _confirm(
      'Clear cache?',
      'Cached stories will be removed. Your saved stories and preferences are kept.',
      'Clear',
    );
    if (!confirmed) return;
    await _cubit.clearCache();
    if (mounted) {
      setState(() {});
      showSnackBarMessage(context, 'Cache cleared');
    }
  }

  Future<void> _resetOnboarding() async {
    await _cubit.resetOnboarding();
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingsCubit>().state;
    final brightness = Theme.of(context).brightness;
    final ink = brightness == Brightness.light ? AppColors.lightInk : AppColors.darkInk;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, 0),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Back',
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: ink),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Settings', style: AppTextStyles.displayL.copyWith(color: ink)),
                ],
              ),
            ),
            SettingsSection(
              title: 'Edition',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  ThemeModeSelector(value: state.themeMode, onChanged: _cubit.setThemeMode),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTopics(state),
                ],
              ),
            ),
            SettingsSection(
              title: 'Storage',
              child: Column(
                children: [
                  const SyncTile(),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_outlined),
                    title: const Text('Clear cache'),
                    subtitle: Text('${_cubit.cachedArticleCount} stories cached'),
                    onTap: _clearCache,
                  ),
                ],
              ),
            ),
            const SettingsSection(
              title: 'About',
              child: ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text('Version'),
                subtitle: Text(_version),
              ),
            ),
            if (kDebugMode)
              SettingsSection(
                title: 'Developer',
                child: DeveloperSection(onResetOnboarding: _resetOnboarding),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopics(SettingsState state) {
    if (state.isLoadingTopics) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: ShimmerLoading(height: 96),
      );
    }
    if (state.topics.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: InkWell(onTap: _cubit.loadTopics, child: const Text("Couldn't load topics · Tap to retry")),
      );
    }
    return Column(
      children: [
        for (final topic in state.topics)
          TopicToggleRow(
            topic: topic,
            isSelected: state.isSelected(topic.id),
            onTap: () => _cubit.toggleTopic(topic.id),
          ),
      ],
    );
  }
}
