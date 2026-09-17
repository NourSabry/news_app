import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/event_transformers.dart';
import '../../../../core/utils/future_extensions.dart';
import '../../domain/search_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

export 'search_event.dart';
export 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  static const debounceDuration = Duration(milliseconds: 400);
  static const searchErrorMessage = "Couldn't search right now";
  static const loadMoreErrorMessage = "Couldn't load more results";

  final SearchRepository _repository;

  /// Bumped every time [_search] starts a fresh result set (G5) — an
  /// in-flight `LoadMoreResults` whose captured generation no longer
  /// matches drops its page instead of appending it to results it no
  /// longer belongs to.
  int _generation = 0;

  SearchBloc(this._repository) : super(const SearchState()) {
    on<SearchStarted>(_onStarted);
    on<QueryChanged>(_onQueryChanged, transformer: debounceRestartable(debounceDuration));
    on<SubmitSearch>(_onSubmit);
    on<LoadMoreResults>(_onLoadMore);
    on<FiltersChanged>(_onFiltersChanged);
    on<SourcesRequested>(_onSourcesRequested, transformer: debounceRestartable(Duration.zero));
    on<ClearSearch>(_onClear);
    on<ClearRecentSearches>(_onClearRecent);
  }

  Future<void> _onStarted(SearchStarted event, Emitter<SearchState> emit) async {
    emit(state.copyWith(recentSearches: _repository.getRecentSearches()));
    final topics = await _repository.getTopics().orFallback(state.topics);
    emit(state.copyWith(topics: topics));
  }

  Future<void> _onQueryChanged(QueryChanged event, Emitter<SearchState> emit) async {
    final query = event.query.trim();
    if (query.isEmpty) return _onClear(const ClearSearch(), emit);
    if (state.hasSearched && state.query == query) return;

    emit(state.copyWith(query: query, hasSearched: false, errorMessage: null));
    final suggestions = await _repository.getSuggestions(query).orFallback(const <String>[]);
    emit(state.copyWith(suggestions: suggestions));
  }

  Future<void> _onSubmit(SubmitSearch event, Emitter<SearchState> emit) async {
    final query = event.query.trim();
    // An empty query with no explicit filters is just the field losing
    // focus — but "Browse sections" submits an empty query with an
    // explicit topic filter, which is a real browse action.
    if (query.isEmpty && event.filters == null) return;

    if (query.isNotEmpty) await _repository.addRecentSearch(query);
    emit(state.copyWith(
      query: query,
      filters: event.filters ?? state.filters,
      recentSearches: _repository.getRecentSearches(),
    ));
    await _search(emit);
  }

  Future<void> _search(Emitter<SearchState> emit) async {
    final generation = ++_generation;
    emit(state.copyWith(
      hasSearched: true,
      isLoading: true,
      results: const [],
      suggestions: const [],
      nextCursor: null,
      errorMessage: null,
    ));
    try {
      final page = await _repository.search(query: state.query, filters: state.filters);
      if (generation != _generation) return;
      emit(state.copyWith(results: page.data, nextCursor: page.nextCursor, isLoading: false));
    } catch (_) {
      if (generation != _generation) return;
      emit(state.copyWith(isLoading: false, errorMessage: searchErrorMessage));
    }
  }

  Future<void> _onLoadMore(LoadMoreResults event, Emitter<SearchState> emit) async {
    if (!state.canLoadMore) return;

    final generation = _generation;
    emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    try {
      final page = await _repository.search(
        query: state.query,
        filters: state.filters,
        cursor: state.nextCursor,
      );
      // A new search started mid-flight replaced the results this page
      // was meant to extend (G5) — appending it now would corrupt them.
      if (generation != _generation) return;
      emit(state.copyWith(
        results: [...state.results, ...page.data],
        nextCursor: page.nextCursor,
        isLoadingMore: false,
      ));
    } catch (_) {
      if (generation != _generation) return;
      emit(state.copyWith(isLoadingMore: false, errorMessage: loadMoreErrorMessage));
    }
  }

  Future<void> _onFiltersChanged(FiltersChanged event, Emitter<SearchState> emit) async {
    emit(state.copyWith(filters: event.filters));
    if (state.hasSearched) await _search(emit);
  }

  Future<void> _onSourcesRequested(SourcesRequested event, Emitter<SearchState> emit) async {
    emit(state.copyWith(isLoadingSources: true));
    final sources = await _repository.getSources(topicId: event.topicId).orFallback(const []);
    emit(state.copyWith(sources: sources, isLoadingSources: false));
  }

  void _onClear(ClearSearch event, Emitter<SearchState> emit) {
    emit(state.copyWith(
      query: '',
      suggestions: const [],
      results: const [],
      nextCursor: null,
      hasSearched: false,
      isLoading: false,
      isLoadingMore: false,
      errorMessage: null,
    ));
  }

  Future<void> _onClearRecent(ClearRecentSearches event, Emitter<SearchState> emit) async {
    await _repository.clearRecentSearches();
    emit(state.copyWith(recentSearches: const []));
  }
}
