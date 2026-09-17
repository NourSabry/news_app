import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/app/deep_link_controller.dart';
import 'package:news_app/core/di/service_locator.dart';
import 'package:news_app/core/network/mock_api_client.dart';
import 'package:news_app/core/storage/local_storage.dart';
import 'package:news_app/features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import 'package:news_app/features/details/presentation/article_details_screen.dart';
import 'package:news_app/features/reactions/presentation/bloc/reactions_bloc.dart';
import 'package:news_app/features/settings/domain/settings_repository.dart';
import 'package:news_app/features/settings/presentation/cubit/settings_cubit.dart';

class MockAppLinks extends Mock implements AppLinks {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockConnectivity extends Mock implements Connectivity {}

class MockCacheManager extends Mock implements BaseCacheManager {}

void main() {
  late MockAppLinks appLinks;
  late MockSettingsRepository settingsRepository;
  late SettingsCubit settingsCubit;
  late StreamController<Uri> linkStream;
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() async {
    // ArticleDetailsScreen (pushed by the routes under test) resolves its
    // own dependencies from ServiceLocator, same as a real feed-card tap.
    final connectivity = MockConnectivity();
    when(() => connectivity.onConnectivityChanged).thenAnswer((_) => const Stream.empty());
    final images = MockCacheManager();
    when(() => images.getFileStream(
          any(),
          key: any(named: 'key'),
          headers: any(named: 'headers'),
          withProgress: any(named: 'withProgress'),
        )).thenAnswer((_) => Stream.error(Exception('No images in tests')));
    ServiceLocator.instance.reset();
    await ServiceLocator.instance.init(
      storage: LocalStorage.inMemory(),
      apiClient: MockApiClient()..latencyMs = 0,
      connectivity: connectivity,
      imageCache: images,
    );

    navigatorKey = GlobalKey<NavigatorState>();
    appLinks = MockAppLinks();
    linkStream = StreamController<Uri>();
    when(() => appLinks.uriLinkStream).thenAnswer((_) => linkStream.stream);
    when(() => appLinks.getInitialLink()).thenAnswer((_) async => null);

    settingsRepository = MockSettingsRepository();
    when(() => settingsRepository.getThemeMode()).thenReturn(ThemeMode.system);
    when(() => settingsRepository.getSelectedTopicIds()).thenReturn(const []);
    when(() => settingsRepository.getOnboardingCompleted()).thenReturn(true);
    when(() => settingsRepository.getTopics()).thenAnswer((_) async => const []);
    when(() => settingsRepository.setOnboardingCompleted(any())).thenAnswer((_) async {});
    settingsCubit = SettingsCubit(settingsRepository);
  });

  tearDown(() async {
    await linkStream.close();
    await settingsCubit.close();
  });

  Future<void> pumpHost(WidgetTester tester) async {
    final locator = ServiceLocator.instance;
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider.value(value: settingsCubit),
        BlocProvider(create: (_) => ReactionsBloc(locator.get())),
        BlocProvider(create: (_) => BookmarksBloc(locator.get())),
      ],
      child: MaterialApp(navigatorKey: navigatorKey, home: const Scaffold(body: Text('home'))),
    ));
  }

  testWidgets('pushes ArticleDetailsScreen when a valid link arrives and onboarding is already done (warm start, X3)',
      (tester) async {
    await pumpHost(tester);
    final controller = DeepLinkController(
      navigatorKey: navigatorKey,
      settings: settingsCubit,
      appLinks: appLinks,
    )..start();
    addTearDown(controller.dispose);
    await tester.pump();

    linkStream.add(Uri.parse('newsfeed://article/a_flutter_roadmap'));
    await tester.pumpAndSettle();

    expect(find.byType(ArticleDetailsScreen), findsOneWidget);
  });

  testWidgets('defers a cold-start link until onboarding completes, then pushes it (X3)', (tester) async {
    when(() => settingsRepository.getOnboardingCompleted()).thenReturn(false);
    settingsCubit = SettingsCubit(settingsRepository);
    when(() => appLinks.getInitialLink())
        .thenAnswer((_) async => Uri.parse('newsfeed://article/a_flutter_roadmap'));

    await pumpHost(tester);
    final controller = DeepLinkController(
      navigatorKey: navigatorKey,
      settings: settingsCubit,
      appLinks: appLinks,
    )..start();
    addTearDown(controller.dispose);
    await tester.pumpAndSettle();

    expect(find.byType(ArticleDetailsScreen), findsNothing);

    await settingsCubit.completeOnboarding();
    // Cubit's stream notifies listeners on a microtask, not synchronously
    // within emit() — the first pump flushes it. Bounded pumps rather than
    // pumpAndSettle: ArticleDetailsScreen's article body loads real
    // (unbundled) network images in this test harness, whose retry/backoff
    // timers never fully settle.
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ArticleDetailsScreen), findsOneWidget);
  });

  testWidgets('a malformed link falls back to a snackbar, never navigating (X3)', (tester) async {
    await pumpHost(tester);
    final controller = DeepLinkController(
      navigatorKey: navigatorKey,
      settings: settingsCubit,
      appLinks: appLinks,
    )..start();
    addTearDown(controller.dispose);
    await tester.pump();

    linkStream.add(Uri.parse('https://example.com/nope'));
    await tester.pumpAndSettle();

    expect(find.byType(ArticleDetailsScreen), findsNothing);
    expect(find.text("That link didn't work"), findsOneWidget);
  });
}
