// Goldens are pixel-exact to the platform that recorded them (font
// rasterisation differs between macOS and Linux), so CI runs this file on a
// macOS runner and excludes it everywhere else.
@Tags(['golden'])
library;

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/connectivity/connectivity_cubit.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/core/theme/app_theme.dart';
import 'package:news_app/core/utils/time_formatter.dart';
import 'package:news_app/core/widgets/freshness_banner.dart';
import 'package:news_app/features/bookmarks/domain/bookmarks_repository.dart';
import 'package:news_app/features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import 'package:news_app/features/feed/domain/feed_repository.dart';
import 'package:news_app/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:news_app/features/feed/presentation/feed_screen.dart';
import 'package:news_app/features/reactions/domain/reactions_repository.dart';
import 'package:news_app/features/reactions/presentation/bloc/reactions_bloc.dart';

/// `test/goldens/` for the five main feed states × light/dark ×
/// text scale 1.0/1.5 = 20 goldens, fixed device size (390×844), bundled
/// fonts. Run `flutter test --update-goldens` after an intentional visual
/// change; a red diff on an unintentional one is the point.
class MockFeedRepository extends Mock implements FeedRepository {}

class MockConnectivityCubit extends MockCubit<ConnectivityStatus>
    implements ConnectivityCubit {}

class MockReactionsRepository extends Mock implements ReactionsRepository {}

class MockBookmarksRepository extends Mock implements BookmarksRepository {}

const _topics = [
  Topic(id: 't_technology', name: 'Technology', icon: 'devices'),
  Topic(id: 't_science', name: 'Science', icon: 'science'),
];

Article _article(
  String id, {
  required String title,
  required String topicId,
}) => Article(
  id: id,
  title: title,
  summary:
      'A short standfirst summarising the story for the reader in one line.',
  source: 'TechWire',
  author: const Author(id: 'u', name: 'Priya Nair'),
  topicId: topicId,
  publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
  likes: 42,
  comments: 5,
);

final _articles = [
  _article(
    'a',
    title: 'Flutter Team Shares the Next Performance Roadmap',
    topicId: 't_technology',
  ),
  _article(
    'b',
    title: 'Battery Breakthrough Improves Grid Storage Efficiency',
    topicId: 't_science',
  ),
  _article(
    'c',
    title: 'Architecture Patterns for Large Scale Apps',
    topicId: 't_technology',
  ),
];

FeedResponse _page(List<Article> data) => FeedResponse(
  data: data,
  page: 1,
  pageSize: data.length,
  total: data.length,
);

void _stubCommon(
  MockFeedRepository repository,
  MockConnectivityCubit connectivity,
) {
  when(() => connectivity.isConnected).thenReturn(true);
  when(() => repository.getSelectedTopicIds()).thenReturn(const []);
  when(() => repository.getTopics()).thenAnswer((_) async => _topics);
  when(() => repository.getTrending()).thenAnswer((_) async => const []);
  when(() => repository.getLastSyncTime()).thenReturn(null);
  when(() => repository.getCachedFeed()).thenReturn(null);
  when(() => repository.getCacheTtlMinutes()).thenAnswer((_) async => 30);
}

/// `LiveArticleCard` (used by every card `FeedScreen` renders) reads these
/// two blocs via `article_sync.dart`'s `BuildContext` extensions.
List<BlocProvider> _cardProviders() {
  final reactionsRepository = MockReactionsRepository();
  when(() => reactionsRepository.loadPersistedOverrides()).thenReturn(const {});
  final bookmarksRepository = MockBookmarksRepository();
  return [
    BlocProvider<ReactionsBloc>(
      create: (_) => ReactionsBloc(reactionsRepository),
    ),
    BlocProvider<BookmarksBloc>(
      create: (_) => BookmarksBloc(bookmarksRepository),
    ),
  ];
}

/// Builds the Scaffold for each of the five feed states. "loading" never lets
/// its fetch resolve, so the bloc stays on the skeleton indefinitely once
/// `screenMatchesGolden`'s bounded `customPump` flushes the first emit —
/// a bare `Future.delayed` here would hang forever instead, the same
/// fake-async-zone trap already hit once in `deep_link_controller_test.dart`.
Widget _buildFeedState(String state) {
  final repository = MockFeedRepository();
  final connectivity = MockConnectivityCubit();
  _stubCommon(repository, connectivity);

  switch (state) {
    case 'loading':
      when(
        () => repository.fetchPage(scope: null),
      ).thenAnswer((_) => Completer<FeedResponse>().future);
    case 'loaded':
      when(
        () => repository.fetchPage(scope: null),
      ).thenAnswer((_) async => _page(_articles));
    case 'empty':
      when(
        () => repository.fetchPage(scope: null),
      ).thenAnswer((_) async => _page(const []));
    case 'error':
      when(
        () => repository.fetchPage(scope: null),
      ).thenThrow(Exception('offline'));
  }

  final bloc = FeedBloc(repository, connectivity)..add(const LoadFeed());

  return Scaffold(
    body: SafeArea(
      child: MultiBlocProvider(
        providers: _cardProviders(),
        child: BlocProvider.value(
          value: bloc,
          child: FeedScreen(onSearchTap: () {}),
        ),
      ),
    ),
  );
}

Widget _buildOfflineStaleState() {
  final repository = MockFeedRepository();
  final connectivity = MockConnectivityCubit();
  _stubCommon(repository, connectivity);
  when(
    () => repository.fetchPage(scope: null),
  ).thenAnswer((_) async => _page(_articles));

  final bloc = FeedBloc(repository, connectivity)..add(const LoadFeed());
  final lastSyncedAt = DateTime.now().subtract(const Duration(hours: 2));

  return Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          FreshnessBanner(
            variant: FreshnessBannerVariant.stale,
            message:
                'Showing stories from ${TimeFormatter.relative(lastSyncedAt)}',
            onRefresh: () {},
          ),
          Expanded(
            child: MultiBlocProvider(
              providers: _cardProviders(),
              child: BlocProvider.value(
                value: bloc,
                child: FeedScreen(onSearchTap: () {}),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  const states = ['loading', 'loaded', 'empty', 'error', 'offline_stale'];
  const brightnesses = {'light': Brightness.light, 'dark': Brightness.dark};
  const textScales = [1.0, 1.5];

  for (final state in states) {
    for (final brightnessEntry in brightnesses.entries) {
      for (final textScale in textScales) {
        testGoldens('Feed $state (${brightnessEntry.key} @${textScale}x)', (
          tester,
        ) async {
          final widget = state == 'offline_stale'
              ? _buildOfflineStaleState()
              : _buildFeedState(state);
          final theme = brightnessEntry.value == Brightness.light
              ? AppTheme.light
              : AppTheme.dark;

          await tester.pumpWidgetBuilder(
            widget,
            wrapper: materialAppWrapper(theme: theme),
            surfaceSize: const Size(390, 844),
            textScaleSize: textScale,
          );

          await screenMatchesGolden(
            tester,
            'feed_${state}_${brightnessEntry.key}_${textScale}x',
            // A few bounded pumps, not pumpAndSettle — some card
            // animations (e.g. the like button's press scale) only ever
            // run on a real tap, but nothing here guarantees the tree is
            // ever fully idle, and this suite only needs a settled frame.
            customPump: (tester) =>
                tester.pump(const Duration(milliseconds: 100)),
          );
        });
      }
    }
  }
}
