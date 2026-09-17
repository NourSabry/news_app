import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/core/network/api_client.dart';
import 'package:news_app/core/storage/local_storage.dart';
import 'package:news_app/features/bookmarks/data/bookmarks_repository_impl.dart';
import 'package:news_app/features/outbox/domain/outbox_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockOutboxRepository extends Mock implements OutboxRepository {}

void main() {
  late MockApiClient api;
  late MockOutboxRepository outbox;
  late LocalStorage storage;
  late BookmarksRepositoryImpl repository;

  OutboxEntry bookmarkEntry(String articleId, bool bookmarked) => OutboxEntry(
        idempotencyKey: 'k_$articleId',
        operation: OutboxOperation.setBookmark,
        payload: {'articleId': articleId, 'bookmarked': bookmarked},
        createdAt: DateTime(2026, 9, 14),
      );

  setUp(() {
    api = MockApiClient();
    outbox = MockOutboxRepository();
    storage = LocalStorage.inMemory();
    repository = BookmarksRepositoryImpl(api, storage, outbox);
    when(() => outbox.enqueue(any(), any())).thenAnswer((_) async {});
  });

  test('merges server ids with a pending outbox add (B1)', () async {
    await storage.saveBookmarkIds({'a'});
    when(() => api.getBookmarkIds()).thenAnswer((_) async => ['a']);
    when(() => outbox.getPending()).thenReturn([bookmarkEntry('b', true)]);

    final result = await repository.reconcileIds();

    expect(result, {'a', 'b'});
  });

  test('drops an id the server still has but a pending remove clears', () async {
    await storage.saveBookmarkIds({'a', 'c'});
    when(() => api.getBookmarkIds()).thenAnswer((_) async => ['a', 'c']);
    when(() => outbox.getPending()).thenReturn([bookmarkEntry('c', false)]);

    final result = await repository.reconcileIds();

    expect(result, {'a'});
  });

  test('pushes an id unknown to both server and outbox back onto the outbox instead of dropping it', () async {
    await storage.saveBookmarkIds({'a', 'orphan'});
    when(() => api.getBookmarkIds()).thenAnswer((_) async => ['a']);
    when(() => outbox.getPending()).thenReturn([]);

    final result = await repository.reconcileIds();

    expect(result, {'a', 'orphan'});
    verify(() => outbox.enqueue(
          OutboxOperation.setBookmark,
          {'articleId': 'orphan', 'bookmarked': true},
        )).called(1);
  });
}
