import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/features/search/domain/search_filters.dart';
import 'package:news_app/features/search/domain/search_repository.dart';
import 'package:news_app/features/search/presentation/bloc/search_bloc.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

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

FeedResponse page(List<Article> data, {String? next}) => FeedResponse(
      data: data,
      page: 1,
      pageSize: data.length,
      total: data.length,
      nextCursor: next,
    );

void main() {
  late MockSearchRepository repository;

  const debounceWait = Duration(milliseconds: 500);

  setUp(() {
    repository = MockSearchRepository();
    when(() => repository.getTopics()).thenAnswer((_) async => topics);
    when(() => repository.getRecentSearches()).thenReturn(const ['flutter']);
    when(() => repository.addRecentSearch(any())).thenAnswer((_) async {});
    when(() => repository.clearRecentSearches()).thenAnswer((_) async {});
  });

  SearchState searched() => SearchState(
        query: 'flutter',
        results: [article('a')],
        nextCursor: 'search_2',
        recentSearches: const ['flutter'],
        hasSearched: true,
      );

  blocTest<SearchBloc, SearchState>(
    'loads recent searches and topics on start',
    build: () => SearchBloc(repository),
    act: (bloc) => bloc.add(const SearchStarted()),
    expect: () => [
      const SearchState(recentSearches: ['flutter']),
      const SearchState(recentSearches: ['flutter'], topics: topics),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'debounces query changes and loads suggestions for the latest one',
    build: () {
      when(() => repository.getSuggestions('flutter'))
          .thenAnswer((_) async => const ['flutter', 'Flutter Roadmap']);
      return SearchBloc(repository);
    },
    act: (bloc) => bloc
      ..add(const QueryChanged('f'))
      ..add(const QueryChanged('fl'))
      ..add(const QueryChanged('flutter ')),
    wait: debounceWait,
    expect: () => [
      const SearchState(query: 'flutter'),
      const SearchState(query: 'flutter', suggestions: ['flutter', 'Flutter Roadmap']),
    ],
    verify: (_) {
      verify(() => repository.getSuggestions('flutter')).called(1);
      verifyNever(() => repository.getSuggestions('f'));
      verifyNever(() => repository.getSuggestions('fl'));
    },
  );

  blocTest<SearchBloc, SearchState>(
    'submitting stores the recent search and loads results',
    build: () {
      when(() => repository.search(query: 'flutter', filters: SearchFilters.none))
          .thenAnswer((_) async => page([article('a')], next: 'search_2'));
      return SearchBloc(repository);
    },
    act: (bloc) => bloc.add(const SubmitSearch(' flutter ')),
    expect: () => [
      const SearchState(query: 'flutter', recentSearches: ['flutter']),
      const SearchState(query: 'flutter', recentSearches: ['flutter'], hasSearched: true, isLoading: true),
      searched(),
    ],
    verify: (_) => verify(() => repository.addRecentSearch('flutter')).called(1),
  );

  blocTest<SearchBloc, SearchState>(
    'emits an error when the search fails',
    build: () {
      when(() => repository.search(query: 'flutter', filters: SearchFilters.none))
          .thenThrow(Exception('offline'));
      return SearchBloc(repository);
    },
    act: (bloc) => bloc.add(const SubmitSearch('flutter')),
    expect: () => [
      const SearchState(query: 'flutter', recentSearches: ['flutter']),
      const SearchState(query: 'flutter', recentSearches: ['flutter'], hasSearched: true, isLoading: true),
      const SearchState(
        query: 'flutter',
        recentSearches: ['flutter'],
        hasSearched: true,
        errorMessage: SearchBloc.searchErrorMessage,
      ),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'appends the next page of results',
    build: () {
      when(() => repository.search(query: 'flutter', filters: SearchFilters.none, cursor: 'search_2'))
          .thenAnswer((_) async => page([article('b')]));
      return SearchBloc(repository);
    },
    seed: searched,
    act: (bloc) => bloc.add(const LoadMoreResults()),
    expect: () => [
      searched().copyWith(isLoadingMore: true),
      searched().copyWith(results: [article('a'), article('b')], nextCursor: null),
    ],
  );

  final loadMoreCompleter = Completer<FeedResponse>();
  blocTest<SearchBloc, SearchState>(
    'a slow load-more page is dropped if a new search lands first (G5)',
    build: () {
      when(() => repository.search(query: 'flutter', filters: SearchFilters.none, cursor: 'search_2'))
          .thenAnswer((_) => loadMoreCompleter.future);
      when(() => repository.search(query: 'other', filters: SearchFilters.none))
          .thenAnswer((_) async => page([article('other')]));
      return SearchBloc(repository);
    },
    seed: searched,
    act: (bloc) async {
      bloc.add(const LoadMoreResults());
      await Future<void>.delayed(Duration.zero);
      // The new search lands and finishes before the delayed load-more
      // page resolves — the out-of-order arrival G5 guards against.
      bloc.add(const SubmitSearch('other'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      loadMoreCompleter.complete(page([article('late')]));
    },
    wait: const Duration(milliseconds: 20),
    verify: (bloc) => expect(bloc.state.results.map((a) => a.id), ['other']),
  );

  blocTest<SearchBloc, SearchState>(
    'changing the topic filter re-runs the active search',
    build: () {
      when(() => repository.search(
            query: 'flutter',
            filters: const SearchFilters(topicId: 't_technology'),
          )).thenAnswer((_) async => page([article('c')]));
      return SearchBloc(repository);
    },
    seed: searched,
    act: (bloc) => bloc.add(const FiltersChanged(SearchFilters(topicId: 't_technology'))),
    expect: () => [
      searched().copyWith(filters: const SearchFilters(topicId: 't_technology')),
      searched().copyWith(
        filters: const SearchFilters(topicId: 't_technology'),
        isLoading: true,
        results: const [],
        nextCursor: null,
      ),
      searched().copyWith(
        filters: const SearchFilters(topicId: 't_technology'),
        results: [article('c')],
        nextCursor: null,
      ),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'an explicit filter set on SubmitSearch replaces a previously set topic (B2)',
    build: () {
      when(() => repository.search(query: 'x', filters: SearchFilters.none))
          .thenAnswer((_) async => page(const []));
      return SearchBloc(repository);
    },
    seed: () => searched().copyWith(filters: const SearchFilters(topicId: 't_technology')),
    act: (bloc) => bloc.add(const SubmitSearch('x', filters: SearchFilters.none)),
    expect: () => [
      searched().copyWith(query: 'x', filters: SearchFilters.none),
      searched().copyWith(
        query: 'x',
        filters: SearchFilters.none,
        hasSearched: true,
        isLoading: true,
        results: const [],
        nextCursor: null,
      ),
      searched().copyWith(query: 'x', filters: SearchFilters.none, results: const [], nextCursor: null),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'submitting without an explicit filter set keeps the current filters',
    build: () {
      when(() => repository.search(query: 'x', filters: const SearchFilters(topicId: 't_technology')))
          .thenAnswer((_) async => page(const []));
      return SearchBloc(repository);
    },
    seed: () => searched().copyWith(filters: const SearchFilters(topicId: 't_technology')),
    act: (bloc) => bloc.add(const SubmitSearch('x')),
    expect: () => [
      searched().copyWith(query: 'x', filters: const SearchFilters(topicId: 't_technology')),
      searched().copyWith(
        query: 'x',
        filters: const SearchFilters(topicId: 't_technology'),
        hasSearched: true,
        isLoading: true,
        results: const [],
        nextCursor: null,
      ),
      searched().copyWith(
        query: 'x',
        filters: const SearchFilters(topicId: 't_technology'),
        results: const [],
        nextCursor: null,
      ),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'clearing resets the query and results but keeps recent searches',
    build: () => SearchBloc(repository),
    seed: searched,
    act: (bloc) => bloc.add(const ClearSearch()),
    expect: () => [
      const SearchState(recentSearches: ['flutter']),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'filters are preserved across a query change (G1)',
    build: () {
      when(() => repository.getSuggestions('flutter')).thenAnswer((_) async => const []);
      return SearchBloc(repository);
    },
    seed: () => const SearchState(filters: SearchFilters(topicId: 't_technology')),
    act: (bloc) => bloc.add(const QueryChanged('flutter')),
    wait: debounceWait,
    verify: (bloc) => expect(bloc.state.filters, const SearchFilters(topicId: 't_technology')),
  );

  blocTest<SearchBloc, SearchState>(
    'SourcesRequested loads the source list for the filter sheet (G1)',
    build: () {
      when(() => repository.getSources(topicId: 't_technology'))
          .thenAnswer((_) async => ['Mobile Daily', 'TechWire']);
      return SearchBloc(repository);
    },
    act: (bloc) => bloc.add(const SourcesRequested('t_technology')),
    expect: () => [
      const SearchState(isLoadingSources: true),
      const SearchState(sources: ['Mobile Daily', 'TechWire']),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'clearing recent searches empties the list',
    build: () => SearchBloc(repository),
    seed: () => const SearchState(recentSearches: ['flutter']),
    act: (bloc) => bloc.add(const ClearRecentSearches()),
    expect: () => [const SearchState()],
    verify: (_) => verify(() => repository.clearRecentSearches()).called(1),
  );
}
