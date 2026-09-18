import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/connectivity/connectivity_cubit.dart';
import '../../domain/outbox_repository.dart';
import 'outbox_state.dart';

export 'outbox_state.dart';

class OutboxCubit extends Cubit<OutboxState> {
  final OutboxRepository _repository;
  late final StreamSubscription<int> _pendingSubscription;
  late final StreamSubscription<ConnectivityStatus> _connectivitySubscription;

  OutboxCubit(OutboxRepository repository, ConnectivityCubit connectivity)
    : _repository = repository,
      super(OutboxState(pendingCount: repository.getPending().length)) {
    _pendingSubscription = _repository.watchPendingCount().listen(
      _onPendingChanged,
    );
    _connectivitySubscription = connectivity.stream.listen(
      _onConnectivityChanged,
    );
    if (connectivity.isConnected) sync();
  }

  void _onPendingChanged(int count) =>
      emit(state.copyWith(pendingCount: count));

  void _onConnectivityChanged(ConnectivityStatus status) {
    if (status == ConnectivityStatus.connected) sync();
  }

  Future<void> sync() async {
    if (state.isSyncing || !state.hasPending) return;
    emit(state.copyWith(isSyncing: true, conflicts: const []));
    try {
      final result = await _repository.sync();
      emit(
        state.copyWith(
          isSyncing: false,
          pendingCount: _repository.getPending().length,
          conflicts: result.conflicts,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isSyncing: false));
    }
  }

  @override
  Future<void> close() async {
    await _pendingSubscription.cancel();
    await _connectivitySubscription.cancel();
    return super.close();
  }
}
