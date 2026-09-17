import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/core/network/api_client.dart';
import 'package:news_app/core/storage/local_storage.dart';
import 'package:news_app/features/outbox/data/outbox_repository_impl.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient api;
  late LocalStorage storage;
  late OutboxRepositoryImpl repository;

  final article = Article(
    id: 'a_flutter_roadmap',
    title: 'Flutter Roadmap',
    summary: 'Summary',
    source: 'Source',
    author: const Author(id: 'u', name: 'Author'),
    topicId: 't_technology',
    publishedAt: DateTime(2026, 9, 14),
  );

  OutboxEntry likeEntry() => OutboxEntry(
        idempotencyKey: 'k1',
        operation: OutboxOperation.toggleReaction,
        payload: const {'articleId': 'a_flutter_roadmap', 'reaction': 'like', 'expectedVersion': 3},
        createdAt: DateTime(2026, 9, 14),
      );

  setUp(() {
    api = MockApiClient();
    storage = LocalStorage.inMemory();
    repository = OutboxRepositoryImpl(api, storage);
  });

  test('maps a server conflict into an OutboxConflict with the cached article title (X1)', () async {
    await storage.cacheArticle(article);
    await storage.addOutboxEntry(likeEntry());
    when(() => api.syncOutbox(baseVersion: any(named: 'baseVersion'), mutations: any(named: 'mutations')))
        .thenAnswer((_) async => {
              'status': 'review_required',
              'newVersion': 1,
              'applied': <String>[],
              'conflicts': [
                {
                  'idempotencyKey': 'k1',
                  'articleId': 'a_flutter_roadmap',
                  'serverState': {'isLiked': true, 'likes': 186, 'version': 5},
                },
              ],
            });

    final result = await repository.sync();

    expect(result.appliedCount, 0);
    expect(result.conflicts, hasLength(1));
    final conflict = result.conflicts.single;
    expect(conflict.articleId, 'a_flutter_roadmap');
    expect(conflict.articleTitle, 'Flutter Roadmap');
    expect(conflict.serverIsLiked, isTrue);
    expect(conflict.serverLikes, 186);
    expect(repository.getPending(), isEmpty);
  });

  test('falls back to a generic title when the article was never cached', () async {
    await storage.addOutboxEntry(likeEntry());
    when(() => api.syncOutbox(baseVersion: any(named: 'baseVersion'), mutations: any(named: 'mutations')))
        .thenAnswer((_) async => {
              'status': 'review_required',
              'newVersion': 1,
              'applied': <String>[],
              'conflicts': [
                {
                  'idempotencyKey': 'k1',
                  'articleId': 'a_flutter_roadmap',
                  'serverState': {'isLiked': false, 'likes': 40, 'version': 2},
                },
              ],
            });

    final result = await repository.sync();

    expect(result.conflicts.single.articleTitle, 'this story');
  });
}
