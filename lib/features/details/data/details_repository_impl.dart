import '../../../core/models/models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../domain/details_repository.dart';

class DetailsRepositoryImpl implements DetailsRepository {
  final ApiClient _api;
  final LocalStorage _storage;

  DetailsRepositoryImpl(this._api, this._storage);

  @override
  Article? getCachedArticle(String id) => _storage.getCachedArticle(id);

  @override
  Future<ArticleResult> fetchArticle(String id) async {
    final result = await _api.getArticle(id);
    if (result is ArticleFound) await _storage.cacheArticle(result.article);
    return result;
  }

  @override
  Future<List<Article>> fetchRelated(List<String> ids) async {
    final articles = await Future.wait(ids.map(_fetchOrCached));
    return articles.whereType<Article>().toList();
  }

  Future<Article?> _fetchOrCached(String id) async {
    try {
      final result = await fetchArticle(id);
      return result is ArticleFound ? result.article : null;
    } catch (_) {
      return getCachedArticle(id);
    }
  }

  @override
  Future<List<Topic>> getTopics() => _api.getTopics();

  @override
  DateTime? getLastSyncTime() => _storage.getLastSyncTime();
}
