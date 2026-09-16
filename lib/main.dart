import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app_shell.dart';
import 'core/connectivity/connectivity_cubit.dart';
import 'core/di/service_locator.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/bookmarks/domain/bookmarks_repository.dart';
import 'features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/outbox/domain/outbox_repository.dart';
import 'features/outbox/presentation/cubit/outbox_cubit.dart';
import 'features/reactions/domain/reactions_repository.dart';
import 'features/reactions/presentation/bloc/reactions_bloc.dart';

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
        BlocProvider(create: (_) => ConnectivityCubit()),
        BlocProvider(
          lazy: false,
          create: (context) => OutboxCubit(
            locator.get<OutboxRepository>(),
            context.read<ConnectivityCubit>(),
          ),
        ),
        BlocProvider(create: (_) => ReactionsBloc(locator.get<ReactionsRepository>())),
        BlocProvider(
          create: (_) => BookmarksBloc(locator.get<BookmarksRepository>())
            ..add(const LoadBookmarks()),
        ),
      ],
      child: MaterialApp(
        title: 'News Feed',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const _AppEntry(),
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
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    final storage = ServiceLocator.instance.get<LocalStorage>();
    _showOnboarding = !storage.getOnboardingCompleted();
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(
        onComplete: () => setState(() => _showOnboarding = false),
      );
    }
    return const AppShell();
  }
}
