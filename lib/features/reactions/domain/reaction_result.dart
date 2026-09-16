import 'article_overrides.dart';

sealed class ReactionResult {
  const ReactionResult();
}

class ReactionApplied extends ReactionResult {
  final int likes;
  final int version;

  const ReactionApplied({required this.likes, required this.version});
}

class ReactionConflict extends ReactionResult {
  final ArticleOverrides serverState;

  const ReactionConflict(this.serverState);
}

class ReactionQueued extends ReactionResult {
  const ReactionQueued();
}
