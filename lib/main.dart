import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app_shell.dart';
import 'core/connectivity/connectivity_cubit.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/bookmarks/domain/bookmarks_repository.dart';
import 'features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/outbox/domain/outbox_repository.dart';
import 'features/outbox/presentation/cubit/outbox_cubit.dart';
import 'features/reactions/domain/reactions_repository.dart';
import 'features/reactions/presentation/bloc/reactions_bloc.dart';
import 'features/settings/domain/settings_repository.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

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
        BlocProvider(create: (_) => SettingsCubit(locator.get<SettingsRepository>())),
        BlocProvider(
          create: (_) => ConnectivityCubit(connectivity: locator.get<Connectivity>()),
        ),
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
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) => previous.themeMode != current.themeMode,
        builder: (_, settings) => MaterialApp(
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

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) {
    final completed = context.select<SettingsCubit, bool>(
      (cubit) => cubit.state.onboardingCompleted,
    );
    return completed ? const AppShell() : const OnboardingScreen();
  }
}
