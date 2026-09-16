import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/features/feed/domain/feed_delta.dart';
import 'package:news_app/features/feed/domain/feed_repository.dart';
import 'package:news_app/features/feed/presentation/bloc/feed_bloc.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

Article article(String id, {int likes = 0}) => Article(
      id: id,
      title: 'Title $id',
      summary: 'Summary',
      source: 'Source',
      author: const Author(id: 'u', name: 'Author'),
      topicId: 't_technology',
      publishedAt: DateTime(2026, 9, 14),
      likes: likes,
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

  setUp(() {
    repository = MockFeedRepository();
    when(() => repository.getTopics()).thenAnswer((_) async => const []);
    when(() => repository.getTrending()).thenAnswer((_) async => const []);
  });

  FeedState loaded() => FeedState(
        status: FeedStatus.success,
        articles: [article('a'), article('b')],
        nextCursor: 'feed_2',
      );

  blocTest<FeedBloc, FeedState>(
    'loads first page with topics and trending',
    build: () {
      when(() => repository.fetchPage()).thenAnswer((_) async => page([article('a')], next: 'feed_2'));
      return FeedBloc(repository);
    },
    act: (bloc) => bloc.add(const LoadFeed()),
    expect: () => [
      const FeedState(status: FeedStatus.loading),
      FeedState(status: FeedStatus.success, articles: [article('a')], nextCursor: 'feed_2'),
    ],
  );

  blocTest<FeedBloc, FeedState>(
    'falls back to cache when the network fails',
    build: () {
      when(() => repository.fetchPage()).thenThrow(Exception('offline'));
      when(() => repository.getCachedFeed()).thenReturn(page([article('cached')]));
      return FeedBloc(repository);
    },
    act: (bloc) => bloc.add(const LoadFeed()),
    expect: () => [
      const FeedState(status: FeedStatus.loading),
      FeedState(status: FeedStatus.success, articles: [article('cached')]),
    ],
  );

  blocTest<FeedBloc, FeedState>(
    'emits failure when the network fails and nothing is cached',
    build: () {
      when(() => repository.fetchPage()).thenThrow(Exception('offline'));
      when(() => repository.getCachedFeed()).thenReturn(null);
      return FeedBloc(repository);
    },
    act: (bloc) => bloc.add(const LoadFeed()),
    expect: () => [
      const FeedState(status: FeedStatus.loading),
      const FeedState(status: FeedStatus.failure, errorMessage: FeedBloc.loadErrorMessage),
    ],
  );

  blocTest<FeedBloc, FeedState>(
    'appends the next page and dedupes by id',
    build: () {
      when(() => repository.fetchPage(cursor: 'feed_2'))
          .thenAnswer((_) async => page([article('b'), article('c')]));
      return FeedBloc(repository);
    },
    seed: loaded,
    act: (bloc) => bloc.add(const LoadMoreFeed()),
    expect: () => [
      loaded().copyWith(isLoadingMore: true),
      loaded().copyWith(articles: [article('a'), article('b'), article('c')], nextCursor: null),
    ],
  );

  blocTest<FeedBloc, FeedState>(
    'ignores load more when there are no more pages',
    build: () => FeedBloc(repository),
    seed: () => loaded().copyWith(nextCursor: null),
    act: (bloc) => bloc.add(const LoadMoreFeed()),
    expect: () => [],
    verify: (_) => verifyNever(() => repository.fetchPage(cursor: any(named: 'cursor'))),
  );

  blocTest<FeedBloc, FeedState>(
    'refresh patches and removes articles and holds new ones as pending',
    build: () {
      when(() => repository.fetchUpdates()).thenAnswer(
        (_) async => FeedDelta(
          newArticles: [article('new'), article('a')],
          updatedArticles: [article('b', likes: 5)],
          deletedIds: const ['a'],
        ),
      );
      return FeedBloc(repository);
    },
    seed: loaded,
    act: (bloc) => bloc.add(const RefreshFeed()),
    expect: () => [
      loaded().copyWith(isRefreshing: true),
      loaded().copyWith(articles: [article('b', likes: 5)], pendingArticles: [article('new')]),
    ],
  );

  blocTest<FeedBloc, FeedState>(
    'showing pending articles prepends them to the feed',
    build: () => FeedBloc(repository),
    seed: () => loaded().copyWith(pendingArticles: [article('new')]),
    act: (bloc) => bloc.add(const ShowPendingArticles()),
    expect: () => [
      loaded().copyWith(articles: [article('new'), article('a'), article('b')]),
    ],
  );
}
