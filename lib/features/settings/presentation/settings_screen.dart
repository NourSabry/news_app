import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snack_bar.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/topic_picker.dart';
import 'cubit/settings_cubit.dart';
import 'widgets/developer_section.dart';
import 'widgets/settings_section.dart';
import 'widgets/sync_tile.dart';
import 'widgets/theme_mode_selector.dart';

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
    if (mounted) showSnackBarMessage(context, 'Cache cleared');
  }

  Future<void> _resetOnboarding() async {
    final confirmed = await _confirm(
      'Reset onboarding?',
      'You will go through the welcome screens again the next time the app opens.',
      'Reset',
    );
    if (!confirmed) return;
    await _cubit.resetOnboarding();
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingsCubit>().state;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: [
          SettingsSection(
            title: 'Appearance',
            child: ThemeModeSelector(value: state.themeMode, onChanged: _cubit.setThemeMode),
          ),
          SettingsSection(title: 'Your topics', child: _buildTopics(state)),
          SettingsSection(
            title: 'Data',
            child: Column(
              children: [
                const SyncTile(),
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: const Text('Clear cache'),
                  subtitle: const Text('Remove cached feed and stories'),
                  onTap: _clearCache,
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt_rounded),
                  title: const Text('Reset onboarding'),
                  subtitle: const Text('Show the welcome screens again'),
                  onTap: _resetOnboarding,
                ),
              ],
            ),
          ),
          if (kDebugMode)
            const SettingsSection(title: 'Developer', child: DeveloperSection()),
        ],
      ),
    );
  }

  Widget _buildTopics(SettingsState state) {
    if (state.isLoadingTopics) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.topics.isEmpty) {
      return ErrorView(message: "Couldn't load topics", onRetry: _cubit.loadTopics);
    }
    return Padding(
      padding: AppSpacing.screenPadding,
      child: TopicPicker(
        shrinkWrap: true,
        topics: state.topics,
        selectedIds: state.selectedTopicIds.toSet(),
        onToggle: _cubit.toggleTopic,
      ),
    );
  }
}
