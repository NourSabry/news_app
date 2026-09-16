import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';

class OutboxState extends Equatable {
  final int pendingCount;
  final bool isSyncing;
  final List<OutboxEntry> conflicts;

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
    List<OutboxEntry>? conflicts,
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
