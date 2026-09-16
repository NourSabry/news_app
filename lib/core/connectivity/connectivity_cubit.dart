import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectivityStatus { connected, disconnected }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(ConnectivityStatus.connected) {
    _init();
  }

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
  }

  void _onChanged(List<ConnectivityResult> results) {
    final isConnected = results.any((r) => r != ConnectivityResult.none);
    emit(isConnected ? ConnectivityStatus.connected : ConnectivityStatus.disconnected);
  }

  bool get isConnected => state == ConnectivityStatus.connected;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
