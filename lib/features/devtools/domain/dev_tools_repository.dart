/// Debug-only controls for demoing offline/error/conflict paths.
/// The presentation layer never touches `MockApiClient` directly — only
/// this repository's implementation does.
abstract class DevToolsRepository {
  bool get simulateOffline;
  bool get simulateServerError;
  bool get simulateConflict;
  bool get simulateReactionFailure;
  int get latencyMs;
  int get cacheTtlMinutes;

  /// Live-feed background poll interval in seconds, default 45.
  int get backgroundTickSeconds;

  void setSimulateOffline(bool value);
  void setSimulateServerError(bool value);
  void setSimulateConflict(bool value);
  void setSimulateReactionFailure(bool value);
  void setLatencyMs(int value);
  void setCacheTtlMinutes(int value);
  void setBackgroundTickSeconds(int value);

  Future<void> resetMockServer();
}
