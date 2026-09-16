import '../../../core/models/models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../outbox/domain/outbox_repository.dart';
import '../domain/bookmarks_repository.dart';

class BookmarksRepositoryImpl implements BookmarksRepository {
  final ApiClient _api;
  final LocalStorage _storage;
  final OutboxRepository _outbox;

  BookmarksRepositoryImpl(this._api, this._storage, this._outbox);

  @override
  Set<String> getIds() => _storage.getBookmarkIds();

  @override
  Future<Set<String>> reconcileIds() async {
    final ids = (await _api.getBookmarkIds()).toSet();
    final pending = _outbox.getPending().where((e) => e.operation == OutboxOperation.setBookmark);
    for (final entry in pending) {
      _apply(ids, entry.payload['articleId'] as String, entry.payload['bookmarked'] as bool);
    }
    await _storage.saveBookmarkIds(ids);
    return ids;
  }

  @override
  Future<void> setBookmark(Article article, {required bool bookmarked}) async {
    final ids = getIds();
    _apply(ids, article.id, bookmarked);
    await _storage.saveBookmarkIds(ids);
    if (bookmarked) await _storage.cacheArticle(article);
    try {
      await _api.setBookmark(articleId: article.id, bookmarked: bookmarked);
    } catch (_) {
      await _outbox.enqueue(
        OutboxOperation.setBookmark,
        {'articleId': article.id, 'bookmarked': bookmarked},
      );
    }
  }

  void _apply(Set<String> ids, String articleId, bool bookmarked) {
    bookmarked ? ids.add(articleId) : ids.remove(articleId);
  }

  @override
  Future<List<Article>> getArticles(Iterable<String> ids) async {
    final articles = await Future.wait(ids.map(_cachedOrFetched));
    return articles.whereType<Article>().toList();
  }

  Future<Article?> _cachedOrFetched(String id) async {
    final cached = _storage.getCachedArticle(id);
    if (cached != null) return cached;
    try {
      final article = await _api.getArticle(id);
      await _storage.cacheArticle(article);
      return article;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Topic>> getTopics() => _api.getTopics();
}
