import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/connectivity/connectivity_cubit.dart';
import '../core/di/service_locator.dart';
import '../core/utils/snack_bar.dart';
import '../core/utils/time_formatter.dart';
import '../core/widgets/floating_dock.dart';
import '../core/widgets/freshness_banner.dart';
import '../features/bookmarks/presentation/saved_screen.dart';
import '../features/devtools/presentation/cubit/dev_tools_cubit.dart';
import '../features/feed/domain/feed_repository.dart';
import '../features/feed/presentation/bloc/feed_bloc.dart';
import '../features/feed/presentation/feed_screen.dart';
import '../features/outbox/presentation/cubit/outbox_cubit.dart';
import '../features/outbox/presentation/widgets/conflict_review_sheet.dart';
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

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  static const _exploreIndex = 1;
  static const _defaultBackgroundTickInterval = Duration(seconds: 45);

  int _currentIndex = 0;
  late final FeedBloc _feedBloc;
  late final SearchBloc _searchBloc = SearchBloc(
    ServiceLocator.instance.get<SearchRepository>(),
  )..add(const SearchStarted());
  final _searchFocusNode = FocusNode();
  Timer? _backgroundTickTimer;
  bool _appInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _feedBloc = FeedBloc(
      ServiceLocator.instance.get<FeedRepository>(),
      context.read<ConnectivityCubit>(),
    )..add(const LoadFeed());
    _scheduleBackgroundTick();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundTickTimer?.cancel();
    _feedBloc.close();
    _searchBloc.close();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause while backgrounded — no point polling a screen nobody can see.
    _appInForeground = state == AppLifecycleState.resumed;
    if (_appInForeground) {
      _scheduleBackgroundTick();
    } else {
      _backgroundTickTimer?.cancel();
    }
  }

  /// Background tick: while Home is visible, online and foregrounded,
  /// silently checks for updates using the same [RefreshFeed] path as
  /// pull-to-refresh, so new stories land in the pending pill without
  /// moving the scroll position. Self-reschedules so a Developer-settings
  /// interval change takes effect on the next tick.
  void _scheduleBackgroundTick() {
    _backgroundTickTimer?.cancel();
    if (!_appInForeground) return;
    final interval = kDebugMode
        ? Duration(
            seconds: context.read<DevToolsCubit>().state.backgroundTickSeconds,
          )
        : _defaultBackgroundTickInterval;
    _backgroundTickTimer = Timer(interval, _onBackgroundTick);
  }

  void _onBackgroundTick() {
    if (_currentIndex == 0 && context.read<ConnectivityCubit>().isConnected) {
      _feedBloc.add(const RefreshFeed());
    }
    _scheduleBackgroundTick();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      _scheduleBackgroundTick();
    } else {
      _backgroundTickTimer?.cancel();
    }
  }

  void _openSearch() {
    _onNavTap(_exploreIndex);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _searchFocusNode.requestFocus(),
    );
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
                    onPressed: () => context.read<ReactionsBloc>().add(
                      ToggleLike(state.retryArticle!),
                    ),
                  ),
          ),
        ),
        BlocListener<OutboxCubit, OutboxState>(
          listenWhen: (previous, current) =>
              current.hasConflicts && previous.conflicts != current.conflicts,
          listener: (context, state) {
            final reactions = context.read<ReactionsBloc>();
            for (final conflict in state.conflicts) {
              reactions.add(
                ApplyOverride(
                  conflict.articleId,
                  ArticleOverrides(
                    isLiked: conflict.serverIsLiked,
                    likes: conflict.serverLikes,
                    version: conflict.serverVersion,
                  ),
                ),
              );
            }
            ConflictReviewSheet.show(context, state.conflicts);
          },
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: [
                BlocProvider.value(
                  value: _feedBloc,
                  child: FeedScreen(
                    onSearchTap: _openSearch,
                    banner: _buildBanner(),
                  ),
                ),
                BlocProvider.value(
                  value: _searchBloc,
                  child: _withBanner(SearchScreen(focusNode: _searchFocusNode)),
                ),
                _withBanner(const SavedScreen()),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingDock(
                currentIndex: _currentIndex,
                onTap: _onNavTap,
                items: [
                  const FloatingDockItem(
                    outlineIcon: Icons.home_outlined,
                    filledIcon: Icons.home_rounded,
                    label: 'Home',
                  ),
                  const FloatingDockItem(
                    outlineIcon: Icons.search_rounded,
                    filledIcon: Icons.search_rounded,
                    label: 'Explore',
                  ),
                  FloatingDockItem(
                    outlineIcon: Icons.bookmark_outline_rounded,
                    filledIcon: Icons.bookmark_rounded,
                    label: 'Saved',
                    showDot: context.select<OutboxCubit, bool>(
                      (cubit) => cubit.state.pendingCount > 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _withBanner(Widget child) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildBanner(),
          Expanded(child: child),
        ],
      ),
    );
  }

  /// The single freshness/sync banner slot — never two banners at once.
  /// Offline and stale take priority over the outbox's own sync status,
  /// since they mean the reader is looking at old data.
  Widget _buildBanner() {
    return BlocBuilder<FeedBloc, FeedState>(
      bloc: _feedBloc,
      builder: (context, feedState) => BlocBuilder<OutboxCubit, OutboxState>(
        builder: (context, outboxState) =>
            _freshnessBanner(feedState, outboxState),
      ),
    );
  }

  Widget _freshnessBanner(FeedState feedState, OutboxState outboxState) {
    switch (feedState.freshness) {
      case FeedFreshness.offline:
        final pending = outboxState.pendingCount;
        final suffix = pending > 0
            ? ' ($pending pending ${pending == 1 ? 'change' : 'changes'})'
            : '';
        return FreshnessBanner(
          key: const ValueKey('freshness-offline'),
          variant: FreshnessBannerVariant.offline,
          message: "You're offline — showing your last edition.$suffix",
        );
      case FeedFreshness.stale:
        return FreshnessBanner(
          key: const ValueKey('freshness-stale'),
          variant: FreshnessBannerVariant.stale,
          message:
              'Showing stories from ${TimeFormatter.relative(feedState.lastSyncedAt!)}',
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
            message:
                '$pending ${pending == 1 ? 'pending change' : 'pending changes'}',
            onTap: () => context.read<OutboxCubit>().sync(),
          );
        }
        return const SizedBox.shrink();
    }
  }
}
