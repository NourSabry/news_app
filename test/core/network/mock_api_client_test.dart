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

  test('getFeed with a trendingLabel matches articles by tag word (B2)', () async {
    final client = MockApiClient(store: MemoryStore())..latencyMs = 0;

    final cleanEnergy = await client.getFeed(trendingLabel: 'Clean Energy');
    final aiPolicy = await client.getFeed(trendingLabel: 'AI Policy');

    expect(cleanEnergy.data.map((a) => a.id), contains('a_solar_farms'));
    expect(cleanEnergy.data.every((a) => a.tags.contains('energy')), isTrue);
    expect(aiPolicy.data.map((a) => a.id), contains('a_ai_policy'));
  });

  test('search honours a publishedAt range (G1)', () async {
    final client = MockApiClient(store: MemoryStore())..latencyMs = 0;

    final result = await client.search(
      query: '',
      publishedFrom: DateTime.parse('2026-09-13T00:00:00Z'),
      publishedTo: DateTime.parse('2026-09-14T23:59:59Z'),
    );

    expect(result.data, isNotEmpty);
    expect(
      result.data.every((a) =>
          !a.publishedAt.isBefore(DateTime.parse('2026-09-13T00:00:00Z')) &&
          !a.publishedAt.isAfter(DateTime.parse('2026-09-14T23:59:59Z'))),
      isTrue,
    );
    expect(result.data.map((a) => a.id), isNot(contains('a_solar_farms')));
  });

  test('search also matches on source name and author name (G1)', () async {
    final client = MockApiClient(store: MemoryStore())..latencyMs = 0;

    final bySource = await client.search(query: 'TechWire');
    final byAuthor = await client.search(query: 'Omar Hassan');

    expect(bySource.data.map((a) => a.id), containsAll(['a_architecture_patterns', 'a_ai_policy']));
    expect(byAuthor.data.every((a) => a.author.name == 'Omar Hassan'), isTrue);
    expect(byAuthor.data.length, greaterThanOrEqualTo(3));
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
