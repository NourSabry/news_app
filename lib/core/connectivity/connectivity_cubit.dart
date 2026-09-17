import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectivityStatus { connected, disconnected }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _simulatedOffline = false;

  ConnectivityCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(ConnectivityStatus.connected) {
    _init();
  }

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
  }

  void _onChanged(List<ConnectivityResult> results) {
    if (_simulatedOffline) return;
    final isConnected = results.any((r) => r != ConnectivityResult.none);
    emit(isConnected ? ConnectivityStatus.connected : ConnectivityStatus.disconnected);
  }

  /// Drives the same offline state a real connectivity drop would (B3) —
  /// Developer settings' "Simulate offline" toggle, not a real network
  /// change. Real connectivity changes are ignored while this is on.
  void setSimulatedOffline(bool offline) {
    _simulatedOffline = offline;
    emit(offline ? ConnectivityStatus.disconnected : ConnectivityStatus.connected);
  }

  bool get isConnected => state == ConnectivityStatus.connected;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
