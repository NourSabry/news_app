import 'reaction_result.dart';

abstract class ReactionsRepository {
  Future<ReactionResult> toggleLike(String articleId, {required int expectedVersion});
}
