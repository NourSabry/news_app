import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/network/mock_api_client.dart';
import 'package:news_app/core/storage/key_value_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('retains bookmarks and like counts across construction over the same store', () async {
    final store = MemoryStore();
    final first = MockApiClient(store: store)..latencyMs = 0;

    await first.setBookmark(articleId: 'a_flutter_roadmap', bookmarked: false);
    await first.setBookmark(articleId: 'a_battery_breakthrough', bookmarked: true);
    await first.toggleReaction(
      articleId: 'a_flutter_roadmap',
      reaction: 'like',
      clientMutationId: 'm1',
      expectedVersion: 3,
    );

    final second = MockApiClient(store: store)..latencyMs = 0;
    final ids = await second.getBookmarkIds();
    final article = await second.getArticle('a_flutter_roadmap');

    expect(ids.toSet(), {'a_startup_funding', 'a_battery_breakthrough'});
    expect(article.isLiked, isTrue);
    expect(article.likes, 185);
    expect(article.version, 4);
  });

  test('resetServerState clears persisted bookmarks and article overrides', () async {
    final store = MemoryStore();
    final first = MockApiClient(store: store)..latencyMs = 0;
    await first.setBookmark(articleId: 'a_battery_breakthrough', bookmarked: true);
    await first.toggleReaction(
      articleId: 'a_flutter_roadmap',
      reaction: 'like',
      clientMutationId: 'm1',
      expectedVersion: 3,
    );

    await first.resetServerState();

    final ids = await first.getBookmarkIds();
    final article = await first.getArticle('a_flutter_roadmap');
    expect(ids.toSet(), {'a_flutter_roadmap', 'a_startup_funding'});
    expect(article.isLiked, isFalse);
    expect(article.likes, 184);
  });
}
