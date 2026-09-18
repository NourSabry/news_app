import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/connectivity/connectivity_cubit.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/features/outbox/domain/outbox_repository.dart';
import 'package:news_app/features/outbox/domain/outbox_sync_result.dart';
import 'package:news_app/features/outbox/presentation/cubit/outbox_cubit.dart';

const _conflict = OutboxConflict(
  articleId: 'a',
  articleTitle: 'Flutter Roadmap',
  serverIsLiked: true,
  serverLikes: 186,
  serverVersion: 5,
);

class MockOutboxRepository extends Mock implements OutboxRepository {}

class MockConnectivityCubit extends MockCubit<ConnectivityStatus> implements ConnectivityCubit {}

OutboxEntry entry(String key) => OutboxEntry(
      idempotencyKey: key,
      operation: OutboxOperation.setBookmark,
      payload: const {'articleId': 'a', 'bookmarked': true},
      createdAt: DateTime(2026, 9, 14),
    );

void main() {
  late MockOutboxRepository repository;
  late MockConnectivityCubit connectivity;
  late StreamController<ConnectivityStatus> connectivityChanges;
  late StreamController<int> pendingChanges;
  late List<OutboxEntry> pending;

  setUp(() {
    repository = MockOutboxRepository();
    connectivity = MockConnectivityCubit();
    connectivityChanges = StreamController<ConnectivityStatus>();
    pendingChanges = StreamController<int>();
    pending = [entry('k1'), entry('k2')];

    when(() => repository.getPending()).thenAnswer((_) => List.of(pending));
    when(() => repository.watchPendingCount()).thenAnswer((_) => pendingChanges.stream);
    when(() => repository.sync()).thenAnswer((_) async {
      final applied = pending.length;
      pending.clear();
      return OutboxSyncResult(appliedCount: applied);
    });
    whenListen(
      connectivity,
      connectivityChanges.stream,
      initialState: ConnectivityStatus.disconnected,
    );
    when(() => connectivity.isConnected).thenReturn(false);
  });

  tearDown(() async {
    await connectivityChanges.close();
    await pendingChanges.close();
  });

  OutboxCubit build() => OutboxCubit(repository, connectivity);

  test('starts with the number of pending entries', () {
    expect(build().state, const OutboxState(pendingCount: 2));
  });

  blocTest<OutboxCubit, OutboxState>(
    'drains the outbox when connectivity comes back',
    build: build,
    act: (_) => connectivityChanges.add(ConnectivityStatus.connected),
    expect: () => const [
      OutboxState(pendingCount: 2, isSyncing: true),
      OutboxState(pendingCount: 0),
    ],
    verify: (_) => verify(() => repository.sync()).called(1),
  );

  blocTest<OutboxCubit, OutboxState>(
    'drains on start when already connected',
    setUp: () => when(() => connectivity.isConnected).thenReturn(true),
    build: build,
    expect: () => const [OutboxState(pendingCount: 0)],
    verify: (_) => verify(() => repository.sync()).called(1),
  );

  blocTest<OutboxCubit, OutboxState>(
    'does nothing when there is nothing pending',
    setUp: () => pending.clear(),
    build: build,
    act: (cubit) => cubit.sync(),
    expect: () => const <OutboxState>[],
    verify: (_) => verifyNever(() => repository.sync()),
  );

  blocTest<OutboxCubit, OutboxState>(
    'keeps pending entries when the sync fails',
    setUp: () => when(() => repository.sync()).thenThrow(Exception('offline')),
    build: build,
    act: (cubit) => cubit.sync(),
    expect: () => const [
      OutboxState(pendingCount: 2, isSyncing: true),
      OutboxState(pendingCount: 2),
    ],
  );

  blocTest<OutboxCubit, OutboxState>(
    'surfaces conflicts the server rejected',
    setUp: () => when(() => repository.sync()).thenAnswer((_) async {
      pending.clear();
      return const OutboxSyncResult(appliedCount: 1, conflicts: [_conflict]);
    }),
    build: build,
    act: (cubit) => cubit.sync(),
    expect: () => const [
      OutboxState(pendingCount: 2, isSyncing: true),
      OutboxState(pendingCount: 0, conflicts: [_conflict]),
    ],
  );

  blocTest<OutboxCubit, OutboxState>(
    'tracks pending count changes from storage',
    build: build,
    act: (_) => pendingChanges.add(3),
    expect: () => const [OutboxState(pendingCount: 3)],
  );
}
