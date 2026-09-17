import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/features/feed/domain/feed_repository.dart';
import 'package:news_app/features/feed/presentation/bloc/feed_bloc.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

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

  setUp(() {
    repository = MockFeedRepository();
    when(() => repository.getSelectedTopicIds()).thenReturn(const []);
    when(() => repository.getTopics()).thenAnswer((_) async => const []);
    when(() => repository.getTrending()).thenAnswer((_) async => const []);
    when(() => repository.getLastSyncTime()).thenReturn(null);
    when(() => repository.getCachedFeed()).thenReturn(null);
  });

  blocTest<FeedBloc, FeedState>(
    'a trending tap scopes the feed without touching search (B2)',
    build: () {
      when(() => repository.fetchPage(scope: null))
          .thenAnswer((_) async => page([article('a'), article('b')]));
      when(() => repository.fetchPage(scope: 'Clean Energy'))
          .thenAnswer((_) async => page([article('c')]));
      return FeedBloc(repository);
    },
    act: (bloc) => bloc
      ..add(const LoadFeed())
      ..add(const FeedScopeChanged('Clean Energy')),
    skip: 2,
    expect: () => [
      isA<FeedState>().having((s) => s.status, 'status', FeedStatus.loading).having((s) => s.scope, 'scope', 'Clean Energy'),
      isA<FeedState>()
          .having((s) => s.status, 'status', FeedStatus.success)
          .having((s) => s.scope, 'scope', 'Clean Energy')
          .having((s) => s.articles, 'articles', [article('c')]),
    ],
  );

  blocTest<FeedBloc, FeedState>(
    'clearing the scope (✕) returns to the personal feed',
    build: () {
      when(() => repository.fetchPage(scope: null)).thenAnswer((_) async => page([article('a')]));
      return FeedBloc(repository);
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
    'load-more while scoped keeps requesting within the scope',
    build: () {
      when(() => repository.fetchPage(cursor: 'next', scope: 'Markets'))
          .thenAnswer((_) async => page([article('b')]));
      return FeedBloc(repository);
    },
    seed: () => FeedState(
      status: FeedStatus.success,
      articles: [article('a')],
      nextCursor: 'next',
      scope: 'Markets',
    ),
    act: (bloc) => bloc.add(const LoadMoreFeed()),
    verify: (_) => verify(() => repository.fetchPage(cursor: 'next', scope: 'Markets')).called(1),
  );
}
