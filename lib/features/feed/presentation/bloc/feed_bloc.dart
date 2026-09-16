import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/models.dart';
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

  final FeedRepository _repository;

  FeedBloc(this._repository) : super(const FeedState()) {
    on<LoadFeed>(_onLoad);
    on<LoadMoreFeed>(_onLoadMore);
    on<RefreshFeed>(_onRefresh);
    on<ShowPendingArticles>(_onShowPending);
  }

  Future<void> _onLoad(LoadFeed event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.loading, errorMessage: null));
    try {
      final (page, topics, trending) = await (
        _repository.fetchPage(),
        _orFallback(_repository.getTopics(), state.topics),
        _orFallback(_repository.getTrending(), state.trending),
      ).wait;
      emit(state.copyWith(
        status: FeedStatus.success,
        articles: page.data,
        pendingArticles: const [],
        topics: topics,
        trending: trending,
        nextCursor: page.nextCursor,
        isRefreshing: false,
      ));
    } catch (_) {
      _recoverFromCache(emit);
    }
  }

  void _recoverFromCache(Emitter<FeedState> emit) {
    final cached = _repository.getCachedFeed();
    if (cached == null) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        errorMessage: loadErrorMessage,
        isRefreshing: false,
      ));
      return;
    }
    emit(state.copyWith(
      status: FeedStatus.success,
      articles: cached.data,
      nextCursor: cached.nextCursor,
      isRefreshing: false,
    ));
  }

  Future<void> _onLoadMore(LoadMoreFeed event, Emitter<FeedState> emit) async {
    final canLoad = state.status == FeedStatus.success && state.hasMore;
    if (!canLoad || state.isLoadingMore || state.isRefreshing) return;

    emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    try {
      final page = await _repository.fetchPage(cursor: state.nextCursor);
      emit(state.copyWith(
        articles: _merge(state.articles, page.data),
        nextCursor: page.nextCursor,
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: loadMoreErrorMessage));
    }
  }

  Future<void> _onRefresh(RefreshFeed event, Emitter<FeedState> emit) async {
    if (state.isRefreshing) return;
    if (state.isEmpty) return _onLoad(const LoadFeed(), emit);

    emit(state.copyWith(isRefreshing: true, errorMessage: null));
    try {
      final (delta, trending) = await (
        _repository.fetchUpdates(),
        _orFallback(_repository.getTrending(), state.trending),
      ).wait;
      emit(state.copyWith(
        articles: _applyDelta(state.articles, delta),
        pendingArticles: _merge(_unseen(delta.newArticles), state.pendingArticles),
        trending: trending,
        isRefreshing: false,
      ));
    } catch (_) {
      emit(state.copyWith(isRefreshing: false, errorMessage: refreshErrorMessage));
    }
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

  Future<T> _orFallback<T>(Future<T> future, T fallback) {
    return future.catchError((Object _) => fallback);
  }
}
