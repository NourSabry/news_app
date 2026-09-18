import 'article_overrides.dart';
import 'reaction_result.dart';

abstract class ReactionsRepository {
  Future<ReactionResult> toggleLike(
    String articleId, {
    required int expectedVersion,
  });

  /// Client-side like overrides persisted from a previous session,
  /// restored so the feed shows the correct liked state before the
  /// network answers.
  Map<String, ArticleOverrides> loadPersistedOverrides();

  Future<void> persistOverride(String articleId, ArticleOverrides value);
}
