import '../../../core/models/models.dart';

abstract class SearchRepository {
  Future<FeedResponse> search({required String query, String? topic, String? cursor});

  Future<List<String>> getSuggestions(String query);

  Future<List<Topic>> getTopics();

  List<String> getRecentSearches();

  Future<void> addRecentSearch(String query);

  Future<void> clearRecentSearches();
}
