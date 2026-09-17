import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/connectivity/connectivity_cubit.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/future_extensions.dart';
import '../../domain/feed_delta.dart';
import '../../domain/feed_repository.dart';
import 'feed_event.dart';
import 'feed_state.dart';

export 'feed_event.dart';
export 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  static const loadErrorMessage = "Couldn't load your feed";
  static const loadMoreErrorMessage = "Couldn't load more stories";
  static const refreshErrorMessage = "Couldn't check for new stories";
  static const noNewStoriesMessage = 'No new stories';

  final FeedRepository _repository;
  final ConnectivityCubit _connectivity;

  /// Bumped by every event that replaces the feed from a clean slate
  /// (a fresh load or a scope change) — never by `LoadMoreFeed`/
  /// `RefreshFeed`, which are continuations of the current load (G5).
  /// A stale continuation whose captured generation no longer matches
  /// drops its result instead of merging it into a feed it doesn't belong
  /// to (e.g. a slow load-more page landing after a topic change).
  int _generation = 0;

  FeedBloc(this._repository, this._connectivity) : super(const FeedState()) {
    on<LoadFeed>(_onLoad);
    on<LoadMoreFeed>(_onLoadMore);
    on<RefreshFeed>(_onRefresh);
    on<ShowPendingArticles>(_onShowPending);
    on<TopicSelectionChanged>(_onLoad);
    on<FeedScopeChanged>(_onScopeChanged);
  }

  Future<void> _onLoad(FeedEvent event, Emitter<FeedState> emit) async {
    final generation = ++_generation;
    // Serve the cache immediately when there is one, instead of a
    // skeleton flash, then silently refresh — the same "cached first,
    // then live" shape DetailsBloc already uses. This is also what lets
    // onboarding's "Start reading" open straight into a populated feed.
    final cached = state.scope == null ? _repository.getCachedFeed() : null;
    emit(state.copyWith(
      status: cached != null ? FeedStatus.success : FeedStatus.loading,
      articles: cached?.data ?? state.articles,
      nextCursor: cached?.nextCursor,
      selectedTopicIds: _repository.getSelectedTopicIds(),
      errorMessage: null,
      notice: null,
      isOffline: !_connectivity.isConnected,
    ));
    try {
      final (page, topics, trending, cacheTtlMinutes) = await (
        _repository.fetchPage(scope: state.scope),
        _repository.getTopics().orFallback(state.topics),
        _repository.getTrending().orFallback(state.trending),
        _repository.getCacheTtlMinutes().orFallback(state.cacheTtlMinutes),
      ).wait;
      if (generation != _generation) return;
      emit(state.copyWith(
        status: FeedStatus.success,
        articles: page.data,
        pendingArticles: const [],
        topics: topics,
        trending: trending,
        lastSyncedAt: _repository.getLastSyncTime(),
        nextCursor: page.nextCursor,
        isRefreshing: false,
        cacheTtlMinutes: cacheTtlMinutes,
        isOffline: !_connectivity.isConnected,
      ));
    } catch (_) {
      if (generation != _generation) return;
      _recoverFromCache(emit);
    }
  }

  Future<void> _onScopeChanged(FeedScopeChanged event, Emitter<FeedState> emit) async {
    final generation = ++_generation;
    emit(state.copyWith(
      status: FeedStatus.loading,
      scope: event.label,
      pendingArticles: const [],
      errorMessage: null,
      notice: null,
    ));
    try {
      final page = await _repository.fetchPage(scope: event.label);
      if (generation != _generation) return;
      emit(state.copyWith(
        status: FeedStatus.success,
        articles: page.data,
        nextCursor: page.nextCursor,
        isRefreshing: false,
      ));
    } catch (_) {
      if (generation != _generation) return;
      emit(state.copyWith(
        status: FeedStatus.failure,
        errorMessage: loadErrorMessage,
        isRefreshing: false,
      ));
    }
  }

  void _recoverFromCache(Emitter<FeedState> emit) {
    final cached = _repository.getCachedFeed();
    if (cached == null) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        errorMessage: loadErrorMessage,
        isRefreshing: false,
        isOffline: !_connectivity.isConnected,
      ));
      return;
    }
    emit(state.copyWith(
      status: FeedStatus.success,
      articles: cached.data,
      lastSyncedAt: _repository.getLastSyncTime(),
      nextCursor: cached.nextCursor,
      isRefreshing: false,
      isOffline: !_connectivity.isConnected,
    ));
  }

  Future<void> _onLoadMore(LoadMoreFeed event, Emitter<FeedState> emit) async {
    final canLoad = state.status == FeedStatus.success && state.hasMore;
    if (!canLoad || state.isLoadingMore || state.isRefreshing) return;

    final generation = _generation;
    emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    try {
      final page = await _repository.fetchPage(cursor: state.nextCursor, scope: state.scope);
      // A topic/scope change mid-flight replaced the feed this page was
      // meant to extend (G5) — merging it now would corrupt the new feed.
      if (generation != _generation) return;
      emit(state.copyWith(
        articles: _merge(state.articles, page.data),
        nextCursor: page.nextCursor,
        isLoadingMore: false,
      ));
    } catch (_) {
      if (generation != _generation) return;
      emit(state.copyWith(isLoadingMore: false, errorMessage: loadMoreErrorMessage));
    }
  }

  Future<void> _onRefresh(RefreshFeed event, Emitter<FeedState> emit) async {
    if (state.isRefreshing) return;
    if (state.isEmpty) return _onLoad(const LoadFeed(), emit);

    final generation = _generation;
    emit(state.copyWith(isRefreshing: true, errorMessage: null, notice: null));
    try {
      final (delta, trending) = await (
        _repository.fetchUpdates(),
        _repository.getTrending().orFallback(state.trending),
      ).wait;
      // Same guard as load-more (G5): a topic/scope change mid-flight
      // means this delta no longer applies to the feed now shown.
      if (generation != _generation) return;
      emit(state.copyWith(
        articles: _applyDelta(state.articles, delta),
        pendingArticles: _merge(_unseen(delta.newArticles), state.pendingArticles),
        trending: trending,
        lastSyncedAt: _repository.getLastSyncTime(),
        isRefreshing: false,
        notice: _refreshNotice(delta),
        isOffline: !_connectivity.isConnected,
      ));
    } catch (_) {
      if (generation != _generation) return;
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: refreshErrorMessage,
        isOffline: !_connectivity.isConnected,
      ));
    }
  }

  /// "1 story removed by publisher" takes priority over "no new stories"
  /// (G3) — a refresh that removed something is never reported as a no-op.
  String? _refreshNotice(FeedDelta delta) {
    if (delta.deletedIds.isNotEmpty) {
      final count = delta.deletedIds.length;
      return '$count ${count == 1 ? 'story' : 'stories'} removed by publisher';
    }
    return delta.isEmpty ? noNewStoriesMessage : null;
  }

  void _onShowPending(ShowPendingArticles event, Emitter<FeedState> emit) {
    if (!state.hasPending) return;
    emit(state.copyWith(
      articles: _merge(state.pendingArticles, state.articles),
      pendingArticles: const [],
    ));
  }

  List<Article> _unseen(List<Article> incoming) {
    final known = state.articles.map((a) => a.id).toSet();
    return incoming.where((a) => !known.contains(a.id)).toList();
  }

  List<Article> _merge(List<Article> first, List<Article> second) {
    final map = _indexById(first);
    for (final article in second) {
      map.putIfAbsent(article.id, () => article);
    }
    return map.values.toList();
  }

  List<Article> _applyDelta(List<Article> articles, FeedDelta delta) {
    final map = _indexById(articles);
    for (final updated in delta.updatedArticles) {
      if (map.containsKey(updated.id)) map[updated.id] = updated;
    }
    delta.deletedIds.forEach(map.remove);
    return map.values.toList();
  }

  Map<String, Article> _indexById(List<Article> articles) {
    return {for (final article in articles) article.id: article};
  }
}
