import 'package:uuid/uuid.dart';
import '../../../core/models/models.dart';
import '../../../core/network/api_client.dart';
import '../../outbox/domain/outbox_repository.dart';
import '../domain/article_overrides.dart';
import '../domain/reaction_result.dart';
import '../domain/reactions_repository.dart';

class ReactionsRepositoryImpl implements ReactionsRepository {
  static const _reaction = 'like';

  final ApiClient _api;
  final OutboxRepository _outbox;
  final Uuid _uuid;

  ReactionsRepositoryImpl(this._api, this._outbox, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  @override
  Future<ReactionResult> toggleLike(String articleId, {required int expectedVersion}) async {
    final mutationId = _uuid.v4();
    try {
      final response = await _api.toggleReaction(
        articleId: articleId,
        reaction: _reaction,
        clientMutationId: mutationId,
        expectedVersion: expectedVersion,
      );
      return _parse(response);
    } catch (_) {
      await _outbox.enqueue(
        OutboxOperation.toggleReaction,
        {'articleId': articleId, 'reaction': _reaction, 'expectedVersion': expectedVersion},
        idempotencyKey: mutationId,
      );
      return const ReactionQueued();
    }
  }

  ReactionResult _parse(Map<String, dynamic> response) {
    if (response['status'] == 'conflict') {
      final serverState = Map<String, dynamic>.from(response['serverState'] as Map);
      return ReactionConflict(ArticleOverrides.fromJson(serverState));
    }
    return ReactionApplied(
      likes: (response['likes'] as num).toInt(),
      version: (response['version'] as num).toInt(),
    );
  }
}
