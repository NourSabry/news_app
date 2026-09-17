import 'package:equatable/equatable.dart';

class DevToolsState extends Equatable {
  final bool simulateOffline;
  final bool simulateServerError;
  final bool simulateConflict;
  final bool simulateReactionFailure;
  final int latencyMs;
  final int cacheTtlMinutes;

  const DevToolsState({
    this.simulateOffline = false,
    this.simulateServerError = false,
    this.simulateConflict = false,
    this.simulateReactionFailure = false,
    this.latencyMs = 400,
    this.cacheTtlMinutes = 30,
  });

  DevToolsState copyWith({
    bool? simulateOffline,
    bool? simulateServerError,
    bool? simulateConflict,
    bool? simulateReactionFailure,
    int? latencyMs,
    int? cacheTtlMinutes,
  }) {
    return DevToolsState(
      simulateOffline: simulateOffline ?? this.simulateOffline,
      simulateServerError: simulateServerError ?? this.simulateServerError,
      simulateConflict: simulateConflict ?? this.simulateConflict,
      simulateReactionFailure: simulateReactionFailure ?? this.simulateReactionFailure,
      latencyMs: latencyMs ?? this.latencyMs,
      cacheTtlMinutes: cacheTtlMinutes ?? this.cacheTtlMinutes,
    );
  }

  @override
  List<Object?> get props => [
        simulateOffline,
        simulateServerError,
        simulateConflict,
        simulateReactionFailure,
        latencyMs,
        cacheTtlMinutes,
      ];
}
