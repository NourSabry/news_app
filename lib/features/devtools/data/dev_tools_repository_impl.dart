import '../../../core/network/mock_api_client.dart';
import '../domain/dev_tools_repository.dart';

class DevToolsRepositoryImpl implements DevToolsRepository {
  final MockApiClient _api;

  DevToolsRepositoryImpl(this._api);

  /// Client-side polling cadence (X2) — not mock-server behaviour, so
  /// unlike the flags above it isn't backed by [_api]; fine to reset to
  /// the default on a fresh app start.
  int _backgroundTickSeconds = 45;

  @override
  bool get simulateOffline => _api.simulateOffline;

  @override
  bool get simulateServerError => _api.simulateError;

  @override
  bool get simulateConflict => _api.simulateConflict;

  @override
  bool get simulateReactionFailure => _api.simulateReactionFailure;

  @override
  int get latencyMs => _api.latencyMs;

  @override
  int get cacheTtlMinutes => _api.cacheTtlMinutes;

  @override
  int get backgroundTickSeconds => _backgroundTickSeconds;

  @override
  void setSimulateOffline(bool value) => _api.simulateOffline = value;

  @override
  void setSimulateServerError(bool value) => _api.simulateError = value;

  @override
  void setSimulateConflict(bool value) => _api.simulateConflict = value;

  @override
  void setSimulateReactionFailure(bool value) => _api.simulateReactionFailure = value;

  @override
  void setLatencyMs(int value) => _api.latencyMs = value;

  @override
  void setCacheTtlMinutes(int value) => _api.cacheTtlMinutes = value;

  @override
  void setBackgroundTickSeconds(int value) => _backgroundTickSeconds = value;

  @override
  Future<void> resetMockServer() => _api.resetServerState();
}
