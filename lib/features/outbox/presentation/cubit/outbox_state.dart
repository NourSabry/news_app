import 'package:equatable/equatable.dart';
import '../../domain/outbox_conflict.dart';

export '../../domain/outbox_conflict.dart';

class OutboxState extends Equatable {
  final int pendingCount;
  final bool isSyncing;
  final List<OutboxConflict> conflicts;

  const OutboxState({
    this.pendingCount = 0,
    this.isSyncing = false,
    this.conflicts = const [],
  });

  bool get hasPending => pendingCount > 0;
  bool get hasConflicts => conflicts.isNotEmpty;

  OutboxState copyWith({
    int? pendingCount,
    bool? isSyncing,
    List<OutboxConflict>? conflicts,
  }) {
    return OutboxState(
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      conflicts: conflicts ?? this.conflicts,
    );
  }

  @override
  List<Object?> get props => [pendingCount, isSyncing, conflicts];
}
