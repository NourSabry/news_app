import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/connectivity/connectivity_cubit.dart';
import '../core/di/service_locator.dart';
import '../core/utils/snack_bar.dart';
import '../core/utils/time_formatter.dart';
import '../core/widgets/edition_nav_bar.dart';
import '../core/widgets/freshness_banner.dart';
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
  static const _exploreIndex = 1;

  int _currentIndex = 0;
  late final FeedBloc _feedBloc;
  late final SearchBloc _searchBloc =
      SearchBloc(ServiceLocator.instance.get<SearchRepository>())..add(const SearchStarted());
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _feedBloc = FeedBloc(
      ServiceLocator.instance.get<FeedRepository>(),
      context.read<ConnectivityCubit>(),
    )..add(const LoadFeed());
  }

  @override
  void dispose() {
    _feedBloc.close();
    _searchBloc.close();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _currentIndex = _exploreIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocusNode.requestFocus());
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
          listener: (context, state) => showSnackBarMessage(
            context,
            state.notice!,
            action: state.retryArticle == null
                ? null
                : SnackBarAction(
                    label: 'Retry',
                    onPressed: () => context
                        .read<ReactionsBloc>()
                        .add(ToggleLike(state.retryArticle!)),
                  ),
          ),
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

  /// The single freshness/sync banner slot (G4) — never two banners at
  /// once. Offline (with pending count) and stale take priority over the
  /// outbox's own sync status, since they mean the reader is looking at
  /// old data, not just waiting on an upload.
  Widget _buildBanner() {
    return BlocBuilder<FeedBloc, FeedState>(
      bloc: _feedBloc,
      builder: (context, feedState) => BlocBuilder<OutboxCubit, OutboxState>(
        builder: (context, outboxState) => _freshnessBanner(feedState, outboxState),
      ),
    );
  }

  Widget _freshnessBanner(FeedState feedState, OutboxState outboxState) {
    switch (feedState.freshness) {
      case FeedFreshness.offline:
        final pending = outboxState.pendingCount;
        final suffix = pending > 0 ? ' ($pending pending ${pending == 1 ? 'change' : 'changes'})' : '';
        return FreshnessBanner(
          key: const ValueKey('freshness-offline'),
          variant: FreshnessBannerVariant.offline,
          message: "You're offline. Showing your last edition.$suffix",
        );
      case FeedFreshness.stale:
        return FreshnessBanner(
          key: const ValueKey('freshness-stale'),
          variant: FreshnessBannerVariant.stale,
          message: 'Showing stories from ${TimeFormatter.relative(feedState.lastSyncedAt!)}',
          onRefresh: () => _feedBloc.add(const RefreshFeed()),
        );
      case FeedFreshness.fresh:
        if (outboxState.isSyncing) {
          return const FreshnessBanner(
            key: ValueKey('freshness-syncing'),
            variant: FreshnessBannerVariant.syncing,
            message: 'Syncing…',
          );
        }
        if (outboxState.pendingCount > 0) {
          final pending = outboxState.pendingCount;
          return FreshnessBanner(
            key: const ValueKey('freshness-pending'),
            variant: FreshnessBannerVariant.syncing,
            animated: false,
            message: '$pending ${pending == 1 ? 'pending change' : 'pending changes'}',
            onTap: () => context.read<OutboxCubit>().sync(),
          );
        }
        return const SizedBox(width: double.infinity);
    }
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        BlocProvider.value(
          value: _feedBloc,
          child: FeedScreen(onSearchTap: _openSearch),
        ),
        BlocProvider.value(
          value: _searchBloc,
          child: SearchScreen(focusNode: _searchFocusNode),
        ),
        const SavedScreen(),
      ],
    );
  }
}
