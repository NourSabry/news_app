import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';

class OutboxSyncResult extends Equatable {
  final int appliedCount;
  final List<OutboxEntry> conflicts;

  const OutboxSyncResult({this.appliedCount = 0, this.conflicts = const []});

  @override
  List<Object?> get props => [appliedCount, conflicts];
}
