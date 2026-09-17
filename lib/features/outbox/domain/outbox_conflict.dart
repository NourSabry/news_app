import 'package:equatable/equatable.dart';

/// A queued mutation the server rejected on sync because its own state had
/// moved on (X1). There's no "force" in the sync response, so the only
/// resolution is to keep the server's value — this just carries what to
/// show and what to apply.
class OutboxConflict extends Equatable {
  final String articleId;
  final String articleTitle;
  final bool serverIsLiked;
  final int serverLikes;
  final int serverVersion;

  const OutboxConflict({
    required this.articleId,
    required this.articleTitle,
    required this.serverIsLiked,
    required this.serverLikes,
    required this.serverVersion,
  });

  @override
  List<Object?> get props => [articleId, articleTitle, serverIsLiked, serverLikes, serverVersion];
}
