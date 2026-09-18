import '../../../core/models/models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../domain/feed_delta.dart';
import '../domain/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  static const _cursorKey = 'feed_next_cursor';

  final ApiClient _api;
  final LocalStorage _storage;

  FeedRepositoryImpl(this._api, this._storage);

  @override
  Future<FeedResponse> fetchPage({String? cursor, String? scope}) async {
    final response = await _api.getFeed(
      cursor: cursor,
      topics: scope == null ? getSelectedTopicIds() : const [],
      trendingLabel: scope,
    );
    if (scope == null) {
      if (cursor == null) {
        await _storage.clearFeedCache();
        await _storage.setLastSyncTime(DateTime.now());
      }
      await _storage.cacheFeedPage(response.page, response.data);
      await _storage.setMeta(_cursorKey, response.nextCursor ?? '');
    }
    return response;
  }

  @override
  FeedResponse? getCachedFeed() {
    final articles = <Article>[];
    for (var page = 1; ; page++) {
      final cached = _storage.getCachedFeedPage(page);
      if (cached.isEmpty) break;
      articles.addAll(_selected(cached));
    }
    if (articles.isEmpty) return null;

    final cursor = _storage.getMeta(_cursorKey);
    return FeedResponse(
      data: articles,
      page: 1,
      pageSize: articles.length,
      total: articles.length,
      nextCursor: (cursor == null || cursor.isEmpty) ? null : cursor,
    );
  }

  @override
  Future<FeedDelta> fetchUpdates() async {
    final since = _storage.getLastSyncTime() ?? DateTime.now();
    final update = await _api.getFeedUpdates(since);
    final newArticles = await _fetchArticles(update.newItems);
    final updatedArticles = await _fetchArticles(update.updatedItems);
    await _storage.setLastSyncTime(update.serverTime);
    return FeedDelta(
      newArticles: _selected(newArticles),
      updatedArticles: updatedArticles,
      deletedIds: update.deletedItems,
    );
  }

  List<Article> _selected(List<Article> articles) {
    final ids = getSelectedTopicIds();
    if (ids.isEmpty) return articles;
    return articles.where((a) => ids.contains(a.topicId)).toList();
  }

  Future<List<Article>> _fetchArticles(List<String> ids) async {
    final results = await Future.wait(ids.map(_api.getArticle));
    final articles = results
        .whereType<ArticleFound>()
        .map((r) => r.article)
        .toList();
    await Future.wait(articles.map(_storage.cacheArticle));
    return articles;
  }

  @override
  Future<List<Topic>> getTopics() => _api.getTopics();

  @override
  Future<List<TrendingTopic>> getTrending() async {
    final raw = await _api.getTrending();
    return raw.map(TrendingTopic.fromJson).toList();
  }

  @override
  List<String> getSelectedTopicIds() => _storage.getSelectedTopicIds();

  @override
  DateTime? getLastSyncTime() => _storage.getLastSyncTime();

  @override
  Future<int> getCacheTtlMinutes() async {
    final flags = await _api.getFlags();
    return flags['cacheTtlMinutes'] as int? ?? 30;
  }
}
