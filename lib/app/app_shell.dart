import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/service_locator.dart';
import '../core/utils/snack_bar.dart';
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

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _exploreIndex = 1;

  int _currentIndex = 0;
  late final SearchBloc _searchBloc =
      SearchBloc(ServiceLocator.instance.get<SearchRepository>())..add(const SearchStarted());

  @override
  void dispose() {
    _searchBloc.close();
    super.dispose();
  }

  void _searchTrending(String label) {
    _searchBloc.add(SubmitSearch(label));
    setState(() => _currentIndex = _exploreIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: theme.dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                activeIcon: Icon(Icons.search_rounded),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_outline_rounded),
                activeIcon: Icon(Icons.bookmark_rounded),
                label: 'Saved',
              ),
            ],
          ),
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
        BlocProvider(
          create: (_) => FeedBloc(ServiceLocator.instance.get<FeedRepository>())
            ..add(const LoadFeed()),
          child: FeedScreen(onTrendingTap: _searchTrending),
        ),
        BlocProvider.value(value: _searchBloc, child: const SearchScreen()),
        const SavedScreen(),
      ],
    );
  }
}
