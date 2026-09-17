/// Debug-only controls for demoing offline/error/conflict paths (B3).
/// The presentation layer never touches `MockApiClient` directly — only
/// this repository's implementation does.
abstract class DevToolsRepository {
  bool get simulateOffline;
  bool get simulateServerError;
  bool get simulateConflict;
  int get latencyMs;

  void setSimulateOffline(bool value);
  void setSimulateServerError(bool value);
  void setSimulateConflict(bool value);
  void setLatencyMs(int value);

  Future<void> resetMockServer();
}
