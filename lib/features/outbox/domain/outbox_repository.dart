import '../../../core/models/models.dart';
import 'outbox_sync_result.dart';

abstract class OutboxRepository {
  List<OutboxEntry> getPending();

  Stream<int> watchPendingCount();

  Future<void> enqueue(
    String operation,
    Map<String, dynamic> payload, {
    String? idempotencyKey,
  });

  Future<OutboxSyncResult> sync();
}
