import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/service_locator.dart';
import '../core/widgets/offline_banner.dart';
import '../features/feed/domain/feed_repository.dart';
import '../features/feed/presentation/bloc/feed_bloc.dart';
import '../features/feed/presentation/feed_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: _buildBody()),
        ],
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
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        BlocProvider(
          create: (_) => FeedBloc(ServiceLocator.instance.get<FeedRepository>())
            ..add(const LoadFeed()),
          child: const FeedScreen(),
        ),
        const _PlaceholderTab(title: 'Explore', icon: Icons.search_rounded),
        const _PlaceholderTab(title: 'Saved', icon: Icons.bookmark_rounded),
      ],
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderTab({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}
