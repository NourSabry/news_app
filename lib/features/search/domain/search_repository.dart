import '../../../core/models/models.dart';
import 'search_filters.dart';

abstract class SearchRepository {
  Future<FeedResponse> search({
    required String query,
    SearchFilters filters = SearchFilters.none,
    String? cursor,
  });

  Future<List<String>> getSuggestions(String query);

  Future<List<Topic>> getTopics();

  /// One representative image per topic id, for the Explore browse grid.
  Future<Map<String, String>> getSectionCovers();

  /// Sources available for the given topics (all sources when empty), for
  /// the filter sheet's Source section.
  Future<List<String>> getSources({Set<String> topicIds = const {}});

  List<String> getRecentSearches();

  Future<void> addRecentSearch(String query);

  Future<void> clearRecentSearches();
}
