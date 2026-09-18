import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/connectivity/connectivity_cubit.dart';
import '../../domain/dev_tools_repository.dart';
import 'dev_tools_state.dart';

export 'dev_tools_state.dart';

class DevToolsCubit extends Cubit<DevToolsState> {
  final DevToolsRepository _repository;
  final ConnectivityCubit _connectivity;

  DevToolsCubit(this._repository, this._connectivity)
    : super(
        DevToolsState(
          simulateOffline: _repository.simulateOffline,
          simulateServerError: _repository.simulateServerError,
          simulateConflict: _repository.simulateConflict,
          simulateReactionFailure: _repository.simulateReactionFailure,
          latencyMs: _repository.latencyMs,
          cacheTtlMinutes: _repository.cacheTtlMinutes,
          backgroundTickSeconds: _repository.backgroundTickSeconds,
        ),
      );

  void setSimulateOffline(bool value) {
    _repository.setSimulateOffline(value);
    _connectivity.setSimulatedOffline(value);
    emit(state.copyWith(simulateOffline: value));
  }

  void setSimulateServerError(bool value) {
    _repository.setSimulateServerError(value);
    emit(state.copyWith(simulateServerError: value));
  }

  void setSimulateConflict(bool value) {
    _repository.setSimulateConflict(value);
    emit(state.copyWith(simulateConflict: value));
  }

  void setSimulateReactionFailure(bool value) {
    _repository.setSimulateReactionFailure(value);
    emit(state.copyWith(simulateReactionFailure: value));
  }

  void setLatencyMs(int value) {
    _repository.setLatencyMs(value);
    emit(state.copyWith(latencyMs: value));
  }

  void setCacheTtlMinutes(int value) {
    _repository.setCacheTtlMinutes(value);
    emit(state.copyWith(cacheTtlMinutes: value));
  }

  void setBackgroundTickSeconds(int value) {
    _repository.setBackgroundTickSeconds(value);
    emit(state.copyWith(backgroundTickSeconds: value));
  }

  Future<void> resetMockServer() => _repository.resetMockServer();
}
