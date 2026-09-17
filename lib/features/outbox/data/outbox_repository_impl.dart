import 'package:uuid/uuid.dart';
import '../../../core/models/models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../domain/outbox_conflict.dart';
import '../domain/outbox_repository.dart';
import '../domain/outbox_sync_result.dart';

class OutboxRepositoryImpl implements OutboxRepository {
  static const _versionKey = 'outbox_version';

  final ApiClient _api;
  final LocalStorage _storage;
  final Uuid _uuid;

  OutboxRepositoryImpl(this._api, this._storage, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  @override
  List<OutboxEntry> getPending() {
    return _storage.getOutboxEntries()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Stream<int> watchPendingCount() => _storage.watchOutboxCount();

  @override
  Future<void> enqueue(
    String operation,
    Map<String, dynamic> payload, {
    String? idempotencyKey,
  }) {
    return _storage.addOutboxEntry(OutboxEntry(
      idempotencyKey: idempotencyKey ?? _uuid.v4(),
      operation: operation,
      payload: payload,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<OutboxSyncResult> sync() async {
    final pending = getPending();
    if (pending.isEmpty) return const OutboxSyncResult();

    final response = await _api.syncOutbox(baseVersion: _baseVersion, mutations: pending);
    final applied = _keys(response['applied']);
    final conflictMaps = (response['conflicts'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final conflictKeys = conflictMaps.map((c) => c['idempotencyKey'] as String).toList();

    await _storage.setMeta(_versionKey, '${response['newVersion'] ?? _baseVersion}');
    for (final key in applied.followedBy(conflictKeys)) {
      await _storage.removeOutboxEntry(key);
    }
    return OutboxSyncResult(
      appliedCount: applied.length,
      conflicts: conflictMaps.map(_toConflict).toList(),
    );
  }

  OutboxConflict _toConflict(Map<String, dynamic> raw) {
    final articleId = raw['articleId'] as String;
    final serverState = raw['serverState'] as Map<String, dynamic>;
    return OutboxConflict(
      articleId: articleId,
      articleTitle: _storage.getCachedArticle(articleId)?.title ?? 'this story',
      serverIsLiked: serverState['isLiked'] as bool,
      serverLikes: serverState['likes'] as int,
      serverVersion: serverState['version'] as int,
    );
  }

  int get _baseVersion => int.tryParse(_storage.getMeta(_versionKey) ?? '') ?? 0;

  List<String> _keys(Object? raw, {String? field}) {
    final items = (raw as List<dynamic>?) ?? const [];
    return items
        .map((item) => field == null ? item as String : (item as Map)[field] as String)
        .toList();
  }
}
