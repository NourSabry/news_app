import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/features/details/domain/details_repository.dart';
import 'package:news_app/features/details/presentation/bloc/details_bloc.dart';

class MockDetailsRepository extends Mock implements DetailsRepository {}

const topics = [Topic(id: 't_technology', name: 'Technology', icon: 'devices')];

Article article(String id, {List<ContentBlock>? body, List<String>? related}) =>
    Article(
      id: id,
      title: 'Title $id',
      summary: 'Summary',
      source: 'Source',
      author: const Author(id: 'u', name: 'Author'),
      topicId: 't_technology',
      publishedAt: DateTime(2026, 9, 14),
      body: body,
      related: related,
    );

const paragraph = ContentBlock(type: 'paragraph', text: 'Body');

void main() {
  late MockDetailsRepository repository;

  final preview = article('a');
  final full = article('a', body: const [paragraph], related: const ['b']);

  setUp(() {
    repository = MockDetailsRepository();
    when(() => repository.getTopics()).thenAnswer((_) async => topics);
    when(
      () => repository.fetchRelated(['b']),
    ).thenAnswer((_) async => [article('b')]);
  });

  blocTest<DetailsBloc, DetailsState>(
    'loads the article and related stories from the network',
    build: () {
      when(() => repository.getCachedArticle('a')).thenReturn(null);
      when(
        () => repository.fetchArticle('a'),
      ).thenAnswer((_) async => ArticleFound(full));
      return DetailsBloc(repository, preview);
    },
    act: (bloc) => bloc.add(const LoadArticle()),
    expect: () => [
      DetailsState(article: preview, isLoading: true),
      DetailsState(article: full, topics: topics),
      DetailsState(article: full, topics: topics, related: [article('b')]),
    ],
    verify: (bloc) => expect(bloc.state.article.body, [paragraph]),
  );

  blocTest<DetailsBloc, DetailsState>(
    'serves the cached article first and then refreshes it',
    build: () {
      when(() => repository.getCachedArticle('a')).thenReturn(full);
      when(
        () => repository.fetchArticle('a'),
      ).thenAnswer((_) async => ArticleFound(full));
      return DetailsBloc(repository, preview);
    },
    act: (bloc) => bloc.add(const LoadArticle()),
    expect: () => [
      DetailsState(article: full, isLoading: true, fromCache: true),
      DetailsState(article: full, topics: topics),
      DetailsState(article: full, topics: topics, related: [article('b')]),
    ],
  );

  blocTest<DetailsBloc, DetailsState>(
    'keeps the cached article when the network fails',
    build: () {
      when(() => repository.getCachedArticle('a')).thenReturn(full);
      when(() => repository.fetchArticle('a')).thenThrow(Exception('offline'));
      return DetailsBloc(repository, preview);
    },
    act: (bloc) => bloc.add(const LoadArticle()),
    expect: () => [
      DetailsState(article: full, isLoading: true, fromCache: true),
      DetailsState(article: full, fromCache: true),
      DetailsState(article: full, fromCache: true, related: [article('b')]),
    ],
    verify: (bloc) => expect(bloc.state.article.body, [paragraph]),
  );

  blocTest<DetailsBloc, DetailsState>(
    'shows the unavailable reason and skips related stories',
    build: () {
      when(() => repository.getCachedArticle('a')).thenReturn(null);
      when(() => repository.fetchArticle('a')).thenAnswer(
        (_) async => const ArticleUnavailable('removed_by_publisher'),
      );
      return DetailsBloc(repository, article('a', related: const ['b']));
    },
    act: (bloc) => bloc.add(const LoadArticle()),
    expect: () => [
      DetailsState(
        article: article('a', related: const ['b']),
        isLoading: true,
      ),
      DetailsState(
        article: article('a', related: const ['b']),
        topics: topics,
        unavailableReason: 'removed_by_publisher',
      ),
    ],
    verify: (bloc) {
      expect(bloc.state.isUnavailable, isTrue);
      verifyNever(() => repository.fetchRelated(any()));
    },
  );

  blocTest<DetailsBloc, DetailsState>(
    'emits an error when the network fails and nothing is cached',
    build: () {
      when(() => repository.getCachedArticle('a')).thenReturn(null);
      when(() => repository.fetchArticle('a')).thenThrow(Exception('offline'));
      return DetailsBloc(repository, preview);
    },
    act: (bloc) => bloc.add(const LoadArticle()),
    expect: () => [
      DetailsState(article: preview, isLoading: true),
      DetailsState(
        article: preview,
        errorMessage: DetailsBloc.loadErrorMessage,
      ),
    ],
    verify: (_) => verifyNever(() => repository.fetchRelated(any())),
  );
}
