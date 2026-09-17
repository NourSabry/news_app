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
    final localIds = getIds();
    final serverIds = (await _api.getBookmarkIds()).toSet();
    final pending = _outbox.getPending().where((e) => e.operation == OutboxOperation.setBookmark);

    final pendingAdds = <String>{};
    final pendingRemoves = <String>{};
    for (final entry in pending) {
      final articleId = entry.payload['articleId'] as String;
      final bookmarked = entry.payload['bookmarked'] as bool;
      (bookmarked ? pendingAdds : pendingRemoves).add(articleId);
    }

    final merged = {...serverIds, ...pendingAdds}..removeAll(pendingRemoves);

    // Ids the server has never heard of and that aren't already queued —
    // e.g. a mutation that "succeeded" against a server that has since
    // forgotten it. Push them to the outbox instead of silently dropping.
    final unknownLocal = localIds
        .difference(serverIds)
        .difference(pendingAdds)
        .difference(pendingRemoves);
    for (final articleId in unknownLocal) {
      merged.add(articleId);
      await _outbox.enqueue(
        OutboxOperation.setBookmark,
        {'articleId': articleId, 'bookmarked': true},
      );
    }

    await _storage.saveBookmarkIds(merged);
    return merged;
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

  /// Never drops a saved id silently (G3) — an unavailable story still
  /// shows in Saved, greyed with "No longer available", using whatever
  /// was cached at bookmark time (bookmarking always caches the article).
  Future<Article?> _cachedOrFetched(String id) async {
    final cached = _storage.getCachedArticle(id);
    try {
      final result = await _api.getArticle(id);
      switch (result) {
        case ArticleFound(:final article):
          await _storage.cacheArticle(article);
          return article;
        case ArticleUnavailable():
          return (cached ?? _unavailableStub(id)).copyWith(isUnavailable: true);
      }
    } catch (_) {
      return cached;
    }
  }

  Article _unavailableStub(String id) {
    return Article(
      id: id,
      title: 'No longer available',
      summary: '',
      source: '',
      author: const Author(id: '', name: ''),
      topicId: '',
      publishedAt: DateTime.now(),
    );
  }

  @override
  Future<List<Topic>> getTopics() => _api.getTopics();
}
