import '../../../core/models/models.dart';
import 'feed_delta.dart';

abstract class FeedRepository {
  /// Fetches a feed page. When [scope] (a trending label) is set, the
  /// user's topic selection is ignored and the result is not written to
  /// the offline cache — a scoped view is ephemeral, not the personal feed.
  Future<FeedResponse> fetchPage({String? cursor, String? scope});

  FeedResponse? getCachedFeed();

  Future<FeedDelta> fetchUpdates();

  Future<List<Topic>> getTopics();

  Future<List<TrendingTopic>> getTrending();

  List<String> getSelectedTopicIds();

  DateTime? getLastSyncTime();

  /// Server-controlled cache TTL, from `/flags`. Overridable via
  /// Developer settings for demoing the stale banner.
  Future<int> getCacheTtlMinutes();
}
