import 'package:equatable/equatable.dart';
import 'outbox_conflict.dart';

class OutboxSyncResult extends Equatable {
  final int appliedCount;
  final List<OutboxConflict> conflicts;

  const OutboxSyncResult({this.appliedCount = 0, this.conflicts = const []});

  @override
  List<Object?> get props => [appliedCount, conflicts];
}
