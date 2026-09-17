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

  /// Sources available for a topic (or all sources when [topicId] is
  /// null), for the filter sheet's Source section.
  Future<List<String>> getSources({String? topicId});

  List<String> getRecentSearches();

  Future<void> addRecentSearch(String query);

  Future<void> clearRecentSearches();
}
