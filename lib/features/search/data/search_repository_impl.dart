import '../../../core/models/models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../domain/search_filters.dart';
import '../domain/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  static const maxRecentSearches = 8;

  final ApiClient _api;
  final LocalStorage _storage;

  SearchRepositoryImpl(this._api, this._storage);

  @override
  Future<FeedResponse> search({
    required String query,
    SearchFilters filters = SearchFilters.none,
    String? cursor,
  }) {
    return _api.search(
      query: query,
      topic: filters.topicId,
      source: filters.source,
      publishedFrom: filters.date?.from,
      publishedTo: filters.date?.to,
      page: _pageFrom(cursor),
    );
  }

  @override
  Future<List<String>> getSources({String? topicId}) async {
    final byTopic = await _api.getSources(topicId: topicId);
    if (topicId != null) return byTopic[topicId] ?? [];
    return byTopic.values.expand((sources) => sources).toSet().toList()..sort();
  }

  int _pageFrom(String? cursor) {
    if (cursor == null) return 1;
    return int.tryParse(cursor.split('_').last) ?? 1;
  }

  @override
  Future<List<String>> getSuggestions(String query) => _api.getSuggestions(query);

  @override
  Future<List<Topic>> getTopics() => _api.getTopics();

  @override
  List<String> getRecentSearches() => _storage.getRecentSearches();

  @override
  Future<void> addRecentSearch(String query) {
    final others = getRecentSearches().where((q) => q.toLowerCase() != query.toLowerCase());
    final updated = [query, ...others].take(maxRecentSearches).toList();
    return _storage.setRecentSearches(updated);
  }

  @override
  Future<void> clearRecentSearches() => _storage.setRecentSearches(const []);
}
