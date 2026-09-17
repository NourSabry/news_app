import 'package:equatable/equatable.dart';

class DevToolsState extends Equatable {
  final bool simulateOffline;
  final bool simulateServerError;
  final bool simulateConflict;
  final bool simulateReactionFailure;
  final int latencyMs;

  const DevToolsState({
    this.simulateOffline = false,
    this.simulateServerError = false,
    this.simulateConflict = false,
    this.simulateReactionFailure = false,
    this.latencyMs = 400,
  });

  DevToolsState copyWith({
    bool? simulateOffline,
    bool? simulateServerError,
    bool? simulateConflict,
    bool? simulateReactionFailure,
    int? latencyMs,
  }) {
    return DevToolsState(
      simulateOffline: simulateOffline ?? this.simulateOffline,
      simulateServerError: simulateServerError ?? this.simulateServerError,
      simulateConflict: simulateConflict ?? this.simulateConflict,
      simulateReactionFailure: simulateReactionFailure ?? this.simulateReactionFailure,
      latencyMs: latencyMs ?? this.latencyMs,
    );
  }

  @override
  List<Object?> get props => [
        simulateOffline,
        simulateServerError,
        simulateConflict,
        simulateReactionFailure,
        latencyMs,
      ];
}
