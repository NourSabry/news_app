import '../../../core/models/models.dart';
import 'feed_delta.dart';

abstract class FeedRepository {
  Future<FeedResponse> fetchPage({String? cursor});

  FeedResponse? getCachedFeed();

  Future<FeedDelta> fetchUpdates();

  Future<List<Topic>> getTopics();

  Future<List<TrendingTopic>> getTrending();
}
