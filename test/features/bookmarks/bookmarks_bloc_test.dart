import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/features/bookmarks/domain/bookmarks_repository.dart';
import 'package:news_app/features/bookmarks/presentation/bloc/bookmarks_bloc.dart';

class MockBookmarksRepository extends Mock implements BookmarksRepository {}

const topics = [Topic(id: 't_technology', name: 'Technology', icon: 'devices')];

Article article(String id) => Article(
  id: id,
  title: 'Title $id',
  summary: 'Summary',
  source: 'Source',
  author: const Author(id: 'u', name: 'Author'),
  topicId: 't_technology',
  publishedAt: DateTime(2026, 9, 14),
);

void main() {
  late MockBookmarksRepository repository;

  setUpAll(() => registerFallbackValue(article('fallback')));

  setUp(() {
    repository = MockBookmarksRepository();
    when(() => repository.getIds()).thenReturn({'a'});
    when(() => repository.getTopics()).thenAnswer((_) async => topics);
    when(() => repository.getArticles(any())).thenAnswer(
      (invocation) async =>
          (invocation.positionalArguments.first as Iterable<String>)
              .map(article)
              .toList(),
    );
    when(
      () => repository.setBookmark(any(), bookmarked: any(named: 'bookmarked')),
    ).thenAnswer((_) async {});
  });

  blocTest<BookmarksBloc, BookmarksState>(
    'shows local bookmarks first, then reconciles with the server',
    build: () {
      when(() => repository.reconcileIds()).thenAnswer((_) async => {'a', 'b'});
      return BookmarksBloc(repository);
    },
    act: (bloc) => bloc.add(const LoadBookmarks()),
    expect: () => [
      const BookmarksState(ids: {'a'}, isLoading: true),
      BookmarksState(
        ids: const {'a', 'b'},
        articles: [article('a'), article('b')],
        topics: topics,
      ),
    ],
    verify: (_) => verify(
      () => repository.getArticles(any(that: equals({'a', 'b'}))),
    ).called(1),
  );

  blocTest<BookmarksBloc, BookmarksState>(
    'keeps local bookmarks when the server is unreachable',
    build: () {
      when(
        () => repository.reconcileIds(),
      ).thenAnswer((_) => Future.error(Exception('offline')));
      when(
        () => repository.getTopics(),
      ).thenAnswer((_) => Future.error(Exception('offline')));
      return BookmarksBloc(repository);
    },
    act: (bloc) => bloc.add(const LoadBookmarks()),
    expect: () => [
      const BookmarksState(ids: {'a'}, isLoading: true),
      BookmarksState(ids: const {'a'}, articles: [article('a')]),
    ],
  );

  blocTest<BookmarksBloc, BookmarksState>(
    'adds a bookmark to the front of the saved list and persists it',
    build: () => BookmarksBloc(repository),
    seed: () => BookmarksState(ids: const {'a'}, articles: [article('a')]),
    act: (bloc) => bloc.add(ToggleBookmark(article('b'))),
    expect: () => [
      BookmarksState(
        ids: const {'a', 'b'},
        articles: [article('b'), article('a')],
      ),
    ],
    verify: (_) => verify(
      () => repository.setBookmark(article('b'), bookmarked: true),
    ).called(1),
  );

  blocTest<BookmarksBloc, BookmarksState>(
    'removes an existing bookmark and persists it',
    build: () => BookmarksBloc(repository),
    seed: () => BookmarksState(
      ids: const {'a', 'b'},
      articles: [article('b'), article('a')],
    ),
    act: (bloc) => bloc.add(ToggleBookmark(article('a'))),
    expect: () => [
      BookmarksState(ids: const {'b'}, articles: [article('b')]),
    ],
    verify: (_) => verify(
      () => repository.setBookmark(article('a'), bookmarked: false),
    ).called(1),
  );

  blocTest<BookmarksBloc, BookmarksState>(
    'toggling twice restores the original bookmark',
    build: () => BookmarksBloc(repository),
    seed: () => BookmarksState(ids: const {'a'}, articles: [article('a')]),
    act: (bloc) => bloc
      ..add(ToggleBookmark(article('a')))
      ..add(ToggleBookmark(article('a'))),
    expect: () => [
      const BookmarksState(),
      BookmarksState(ids: const {'a'}, articles: [article('a')]),
    ],
  );
}
