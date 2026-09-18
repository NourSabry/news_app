import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app_shell.dart';
import 'app/deep_link_controller.dart';
import 'core/connectivity/connectivity_cubit.dart';
import 'core/di/service_locator.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/bookmarks/domain/bookmarks_repository.dart';
import 'features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import 'features/devtools/domain/dev_tools_repository.dart';
import 'features/devtools/presentation/cubit/dev_tools_cubit.dart';
import 'features/feed/domain/feed_repository.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/outbox/domain/outbox_repository.dart';
import 'features/outbox/presentation/cubit/outbox_cubit.dart';
import 'features/reactions/domain/reactions_repository.dart';
import 'features/reactions/presentation/bloc/reactions_bloc.dart';
import 'features/settings/domain/settings_repository.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

/// Shared with [DeepLinkController] so a link can be pushed from outside
/// the widget tree, regardless of which tab is currently showing.
final rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await ServiceLocator.instance.init();

  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locator = ServiceLocator.instance;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SettingsCubit(locator.get<SettingsRepository>()),
        ),
        BlocProvider(
          create: (_) =>
              ConnectivityCubit(connectivity: locator.get<Connectivity>()),
        ),
        BlocProvider(
          lazy: false,
          create: (context) => OutboxCubit(
            locator.get<OutboxRepository>(),
            context.read<ConnectivityCubit>(),
          ),
        ),
        BlocProvider(
          create: (_) => ReactionsBloc(locator.get<ReactionsRepository>()),
        ),
        BlocProvider(
          create: (_) =>
              BookmarksBloc(locator.get<BookmarksRepository>())
                ..add(const LoadBookmarks()),
        ),
        if (kDebugMode)
          BlocProvider(
            create: (context) => DevToolsCubit(
              locator.get<DevToolsRepository>(),
              context.read<ConnectivityCubit>(),
            ),
          ),
        BlocProvider(
          create: (_) => OnboardingCubit(
            locator.get<FeedRepository>(),
            locator.get<ApiClient>(),
          ),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.themeMode != current.themeMode,
        builder: (_, settings) => MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'News Feed',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          home: const _AppEntry(),
        ),
      ),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  late final DeepLinkController _deepLinks;

  @override
  void initState() {
    super.initState();
    _deepLinks = DeepLinkController(
      navigatorKey: rootNavigatorKey,
      settings: context.read<SettingsCubit>(),
    )..start();
  }

  @override
  void dispose() {
    _deepLinks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = context.select<SettingsCubit, bool>(
      (cubit) => cubit.state.onboardingCompleted,
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: completed
          ? const AppShell(key: ValueKey('shell'))
          : const OnboardingScreen(key: ValueKey('onboarding')),
    );
  }
}
