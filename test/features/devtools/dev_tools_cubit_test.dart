import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/connectivity/connectivity_cubit.dart';
import 'package:news_app/features/devtools/domain/dev_tools_repository.dart';
import 'package:news_app/features/devtools/presentation/cubit/dev_tools_cubit.dart';

class MockDevToolsRepository extends Mock implements DevToolsRepository {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockDevToolsRepository repository;
  late ConnectivityCubit connectivity;

  setUp(() {
    repository = MockDevToolsRepository();
    when(() => repository.simulateOffline).thenReturn(false);
    when(() => repository.simulateServerError).thenReturn(false);
    when(() => repository.simulateConflict).thenReturn(false);
    when(() => repository.simulateReactionFailure).thenReturn(false);
    when(() => repository.latencyMs).thenReturn(400);
    when(() => repository.cacheTtlMinutes).thenReturn(30);
    when(() => repository.backgroundTickSeconds).thenReturn(45);
    when(() => repository.setSimulateOffline(any())).thenReturn(null);
    when(() => repository.setSimulateServerError(any())).thenReturn(null);
    when(() => repository.setSimulateConflict(any())).thenReturn(null);
    when(() => repository.setSimulateReactionFailure(any())).thenReturn(null);
    when(() => repository.setLatencyMs(any())).thenReturn(null);
    when(() => repository.setCacheTtlMinutes(any())).thenReturn(null);
    when(() => repository.setBackgroundTickSeconds(any())).thenReturn(null);
    when(() => repository.resetMockServer()).thenAnswer((_) async {});

    final mockConnectivity = MockConnectivity();
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => const Stream.empty());
    connectivity = ConnectivityCubit(connectivity: mockConnectivity);
  });

  test('starts from the repository\'s current values', () {
    when(() => repository.simulateOffline).thenReturn(true);
    when(() => repository.latencyMs).thenReturn(2000);

    final cubit = DevToolsCubit(repository, connectivity);

    expect(cubit.state.simulateOffline, isTrue);
    expect(cubit.state.latencyMs, 2000);
  });

  blocTest<DevToolsCubit, DevToolsState>(
    'toggling simulate offline also drives ConnectivityCubit (B3)',
    build: () => DevToolsCubit(repository, connectivity),
    act: (cubit) => cubit.setSimulateOffline(true),
    expect: () => [const DevToolsState(simulateOffline: true)],
    verify: (_) {
      verify(() => repository.setSimulateOffline(true)).called(1);
      expect(connectivity.state, ConnectivityStatus.disconnected);
    },
  );

  blocTest<DevToolsCubit, DevToolsState>(
    'turning simulate offline back off reconnects',
    build: () => DevToolsCubit(repository, connectivity),
    act: (cubit) => cubit
      ..setSimulateOffline(true)
      ..setSimulateOffline(false),
    expect: () => [
      const DevToolsState(simulateOffline: true),
      const DevToolsState(simulateOffline: false),
    ],
    verify: (_) => expect(connectivity.state, ConnectivityStatus.connected),
  );

  blocTest<DevToolsCubit, DevToolsState>(
    'setLatencyMs updates state and the repository',
    build: () => DevToolsCubit(repository, connectivity),
    act: (cubit) => cubit.setLatencyMs(2000),
    expect: () => [const DevToolsState(latencyMs: 2000)],
    verify: (_) => verify(() => repository.setLatencyMs(2000)).called(1),
  );

  blocTest<DevToolsCubit, DevToolsState>(
    'setSimulateReactionFailure updates state and the repository (G2)',
    build: () => DevToolsCubit(repository, connectivity),
    act: (cubit) => cubit.setSimulateReactionFailure(true),
    expect: () => [const DevToolsState(simulateReactionFailure: true)],
    verify: (_) => verify(() => repository.setSimulateReactionFailure(true)).called(1),
  );

  blocTest<DevToolsCubit, DevToolsState>(
    'setCacheTtlMinutes updates state and the repository (G4)',
    build: () => DevToolsCubit(repository, connectivity),
    act: (cubit) => cubit.setCacheTtlMinutes(0),
    expect: () => [const DevToolsState(cacheTtlMinutes: 0)],
    verify: (_) => verify(() => repository.setCacheTtlMinutes(0)).called(1),
  );

  blocTest<DevToolsCubit, DevToolsState>(
    'setBackgroundTickSeconds updates state and the repository (X2)',
    build: () => DevToolsCubit(repository, connectivity),
    act: (cubit) => cubit.setBackgroundTickSeconds(10),
    expect: () => [const DevToolsState(backgroundTickSeconds: 10)],
    verify: (_) => verify(() => repository.setBackgroundTickSeconds(10)).called(1),
  );

  test('resetMockServer delegates to the repository', () async {
    final cubit = DevToolsCubit(repository, connectivity);
    await cubit.resetMockServer();
    verify(() => repository.resetMockServer()).called(1);
  });
}
