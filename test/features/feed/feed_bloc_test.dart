import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/connectivity/connectivity_cubit.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/features/feed/domain/feed_delta.dart';
import 'package:news_app/features/feed/domain/feed_repository.dart';
import 'package:news_app/features/feed/presentation/bloc/feed_bloc.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

class MockConnectivityCubit extends MockCubit<ConnectivityStatus>
    implements ConnectivityCubit {}

Article article(String id, {String topicId = 't_technology'}) => Article(
  id: id,
  title: 'Title $id',
  summary: 'Summary',
  source: 'Source',
  author: const Author(id: 'u', name: 'Author'),
  topicId: topicId,
  publishedAt: DateTime(2026, 9, 14),
);

FeedResponse page(List<Article> data, {String? next}) => FeedResponse(
  data: data,
  page: 1,
  pageSize: data.length,
  total: data.length,
  nextCursor: next,
);

void main() {
  late MockFeedRepository repository;
  late MockConnectivityCubit connectivity;

  setUp(() {
    repository = MockFeedRepository();
    connectivity = MockConnectivityCubit();
    when(() => repository.getSelectedTopicIds()).thenReturn(const []);
    when(() => repository.getTopics()).thenAnswer((_) async => const []);
    when(() => repository.getTrending()).thenAnswer((_) async => const []);
    when(() => repository.getLastSyncTime()).thenReturn(null);
    when(() => repository.getCachedFeed()).thenReturn(null);
    when(() => repository.getCacheTtlMinutes()).thenAnswer((_) async => 30);
    when(() => connectivity.isConnected).thenReturn(true);
  });

  blocTest<FeedBloc, FeedState>(
    'a trending tap scopes the feed without touching search',
    build: () {
      when(
        () => repository.fetchPage(scope: null),
      ).thenAnswer((_) async => page([article('a'), article('b')]));
      when(
        () => repository.fetchPage(scope: 'Clean Energy'),
      ).thenAnswer((_) async => page([article('c')]));
      return FeedBloc(repository, connectivity);
    },
    act: (bloc) => bloc
      ..add(const LoadFeed())
      ..add(const FeedScopeChanged('Clean Energy')),
    skip: 2,
    expect: () => [
      isA<FeedState>()
          .having((s) => s.status, 'status', FeedStatus.loading)
          .having((s) => s.scope, 'scope', 'Clean Energy'),
      isA<FeedState>()
          .having((s) => s.status, 'status', FeedStatus.success)
          .having((s) => s.scope, 'scope', 'Clean Energy')
          .having((s) => s.articles, 'articles', [article('c')]),
    ],
  );

  blocTest<FeedBloc, FeedState>(
    'clearing the scope (✕) returns to the personal feed',
    build: () {
      when(
        () => repository.fetchPage(scope: null),
      ).thenAnswer((_) async => page([article('a')]));
      return FeedBloc(repository, connectivity);
    },
    seed: () => FeedState(
      status: FeedStatus.success,
      articles: [article('c')],
      scope: 'Clean Energy',
    ),
    act: (bloc) => bloc.add(const FeedScopeChanged(null)),
    skip: 1,
    expect: () => [
      isA<FeedState>()
          .having((s) => s.status, 'status', FeedStatus.success)
          .having((s) => s.scope, 'scope', isNull)
          .having((s) => s.articles, 'articles', [article('a')]),
    ],
  );

  blocTest<FeedBloc, FeedState>(
    'reports offline (from ConnectivityCubit) when a fresh load fails, not just a network error',
    build: () {
      when(() => connectivity.isConnected).thenReturn(false);
      when(
        () => repository.fetchPage(scope: null),
      ).thenThrow(Exception('offline'));
      when(() => repository.getCachedFeed()).thenReturn(page([article('a')]));
      return FeedBloc(repository, connectivity);
    },
    act: (bloc) => bloc.add(const LoadFeed()),
    expect: () => [
      isA<FeedState>()
          .having((s) => s.status, 'status', FeedStatus.success)
          .having((s) => s.isOffline, 'isOffline', isTrue)
          .having((s) => s.freshness, 'freshness', FeedFreshness.offline),
    ],
  );

  final loadMoreCompleter = Completer<FeedResponse>();
  blocTest<FeedBloc, FeedState>(
    'a slow load-more page is dropped if a topic change lands first',
    build: () {
      when(
        () => repository.fetchPage(cursor: 'next', scope: null),
      ).thenAnswer((_) => loadMoreCompleter.future);
      when(
        () => repository.fetchPage(scope: null),
      ).thenAnswer((_) async => page([article('new-topic')]));
      return FeedBloc(repository, connectivity);
    },
    seed: () => FeedState(
      status: FeedStatus.success,
      articles: [article('a')],
      nextCursor: 'next',
    ),
    act: (bloc) async {
      bloc.add(const LoadMoreFeed());
      await Future<void>.delayed(Duration.zero);
      // The topic change lands and completes fully before the load-more
      // page (still in flight) resolves — the exact ordering the generation guard protects
      // against.
      bloc.add(const TopicSelectionChanged());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      loadMoreCompleter.complete(page([article('late')]));
    },
    wait: const Duration(milliseconds: 20),
    verify: (bloc) {
      expect(bloc.state.articles.map((a) => a.id), ['new-topic']);
    },
  );

  blocTest<FeedBloc, FeedState>(
    'a refresh that removes a story notices it and drops it from the feed',
    build: () {
      when(
        () => repository.fetchUpdates(),
      ).thenAnswer((_) async => const FeedDelta(deletedIds: ['a']));
      when(() => repository.getTrending()).thenAnswer((_) async => const []);
      return FeedBloc(repository, connectivity);
    },
    seed: () => FeedState(
      status: FeedStatus.success,
      articles: [article('a'), article('b')],
    ),
    act: (bloc) => bloc.add(const RefreshFeed()),
    skip: 1,
    expect: () => [
      isA<FeedState>()
          .having((s) => s.articles.map((a) => a.id), 'articles', ['b'])
          .having((s) => s.notice, 'notice', '1 story removed by publisher'),
    ],
  );

  blocTest<FeedBloc, FeedState>(
    'load-more while scoped keeps requesting within the scope',
    build: () {
      when(
        () => repository.fetchPage(cursor: 'next', scope: 'Markets'),
      ).thenAnswer((_) async => page([article('b')]));
      return FeedBloc(repository, connectivity);
    },
    seed: () => FeedState(
      status: FeedStatus.success,
      articles: [article('a')],
      nextCursor: 'next',
      scope: 'Markets',
    ),
    act: (bloc) => bloc.add(const LoadMoreFeed()),
    verify: (_) => verify(
      () => repository.fetchPage(cursor: 'next', scope: 'Markets'),
    ).called(1),
  );
}
