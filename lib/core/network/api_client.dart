import '../models/models.dart';

abstract class ApiClient {
  Future<List<Topic>> getTopics();

  Future<Map<String, List<String>>> getSources({String? topicId});

  Future<FeedResponse> getFeed({
    int page = 1,
    int pageSize = 10,
    List<String> topics = const [],
    String? source,
    String? cursor,
    String? trendingLabel,
  });

  Future<Article> getArticle(String id);

  Future<FeedResponse> search({
    required String query,
    int page = 1,
    int pageSize = 10,
    String? topic,
    String? source,
  });

  Future<List<String>> getSuggestions(String query);

  Future<Map<String, dynamic>> toggleReaction({
    required String articleId,
    required String reaction,
    required String clientMutationId,
    required int expectedVersion,
  });

  Future<void> setBookmark({
    required String articleId,
    required bool bookmarked,
  });

  Future<List<String>> getBookmarkIds();

  Future<FeedUpdate> getFeedUpdates(DateTime since);

  Future<Map<String, dynamic>> syncOutbox({
    required int baseVersion,
    required List<OutboxEntry> mutations,
  });

  Future<Map<String, dynamic>> getFlags();

  Future<List<Map<String, dynamic>>> getTrending();
}
