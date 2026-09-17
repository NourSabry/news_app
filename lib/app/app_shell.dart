import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/service_locator.dart';
import '../core/utils/snack_bar.dart';
import '../core/widgets/edition_nav_bar.dart';
import '../core/widgets/offline_banner.dart';
import '../features/bookmarks/presentation/saved_screen.dart';
import '../features/feed/domain/feed_repository.dart';
import '../features/feed/presentation/bloc/feed_bloc.dart';
import '../features/feed/presentation/feed_screen.dart';
import '../features/outbox/presentation/cubit/outbox_cubit.dart';
import '../features/reactions/presentation/bloc/reactions_bloc.dart';
import '../features/search/domain/search_repository.dart';
import '../features/search/presentation/bloc/search_bloc.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  late final FeedBloc _feedBloc =
      FeedBloc(ServiceLocator.instance.get<FeedRepository>())..add(const LoadFeed());
  late final SearchBloc _searchBloc =
      SearchBloc(ServiceLocator.instance.get<SearchRepository>())..add(const SearchStarted());

  @override
  void dispose() {
    _feedBloc.close();
    _searchBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) =>
              previous.selectedTopicIds != current.selectedTopicIds,
          listener: (_, _) => _feedBloc.add(const TopicSelectionChanged()),
        ),
        BlocListener<ReactionsBloc, ReactionsState>(
          listenWhen: (previous, current) =>
              current.notice != null && previous.notice != current.notice,
          listener: (context, state) => showSnackBarMessage(context, state.notice!),
        ),
        BlocListener<OutboxCubit, OutboxState>(
          listenWhen: (previous, current) =>
              current.hasConflicts && previous.conflicts != current.conflicts,
          listener: (context, state) => showSnackBarMessage(
            context,
            '${state.conflicts.length} of your changes were overwritten by newer updates',
          ),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildBanner(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
        bottomNavigationBar: EditionNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            const EditionNavBarItem(
              outlineIcon: Icons.home_outlined,
              filledIcon: Icons.home_rounded,
              label: 'Home',
            ),
            const EditionNavBarItem(
              outlineIcon: Icons.search_rounded,
              filledIcon: Icons.search_rounded,
              label: 'Explore',
            ),
            EditionNavBarItem(
              outlineIcon: Icons.bookmark_outline_rounded,
              filledIcon: Icons.bookmark_rounded,
              label: 'Saved',
              showDot: context.select<OutboxCubit, bool>((cubit) => cubit.state.pendingCount > 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return BlocBuilder<OutboxCubit, OutboxState>(
      builder: (context, state) => OfflineBanner(
        pendingCount: state.pendingCount,
        isSyncing: state.isSyncing,
        onSync: context.read<OutboxCubit>().sync,
      ),
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        BlocProvider.value(
          value: _feedBloc,
          child: const FeedScreen(),
        ),
        BlocProvider.value(value: _searchBloc, child: const SearchScreen()),
        const SavedScreen(),
      ],
    );
  }
}
