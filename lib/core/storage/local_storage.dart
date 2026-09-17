import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'hive_store.dart';
import 'key_value_store.dart';

class LocalStorage {
  final KeyValueStore _feedCache;
  final KeyValueStore _articles;
  final KeyValueStore _bookmarks;
  final KeyValueStore _outbox;
  final KeyValueStore _meta;

  /// The mock backend's own state (Part 1, B1) — a separate box so
  /// "Clear cache" in Settings never touches it, only "Reset mock server".
  final KeyValueStore mockServerStore;

  LocalStorage({
    required KeyValueStore feedCache,
    required KeyValueStore articles,
    required KeyValueStore bookmarks,
    required KeyValueStore outbox,
    required KeyValueStore meta,
    required this.mockServerStore,
  })  : _feedCache = feedCache,
        _articles = articles,
        _bookmarks = bookmarks,
        _outbox = outbox,
        _meta = meta;

  factory LocalStorage.inMemory() {
    return LocalStorage(
      feedCache: MemoryStore(),
      articles: MemoryStore(),
      bookmarks: MemoryStore(),
      outbox: MemoryStore(),
      meta: MemoryStore(),
      mockServerStore: MemoryStore(),
    );
  }

  static Future<LocalStorage> openHive() async {
    await Hive.initFlutter();
    return LocalStorage(
      feedCache: await HiveStore.open('feed_cache'),
      articles: await HiveStore.open('articles'),
      bookmarks: await HiveStore.open('bookmarks'),
      outbox: await HiveStore.open('outbox'),
      meta: await HiveStore.open('meta'),
      mockServerStore: await HiveStore.open('mock_server'),
    );
  }

  Future<void> cacheFeedPage(int page, List<Article> articles) async {
    final jsonList = articles.map((a) => json.encode(a.toJson())).toList();
    await _feedCache.put('page_$page', json.encode(jsonList));
  }

  List<Article> getCachedFeedPage(int page) {
    final raw = _feedCache.get('page_$page');
    if (raw == null) return [];
    final jsonList = (json.decode(raw) as List<dynamic>).cast<String>();
    return jsonList
        .map((e) => Article.fromJson(json.decode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearFeedCache() async {
    await _feedCache.clear();
  }

  Future<void> cacheArticle(Article article) async {
    await _articles.put(article.id, json.encode(article.toJson()));
  }

  Article? getCachedArticle(String id) {
    final raw = _articles.get(id);
    if (raw == null) return null;
    return Article.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  Future<void> clearArticleCache() async {
    await _articles.clear();
  }

  Future<void> saveBookmarkIds(Set<String> ids) async {
    await _bookmarks.put('ids', json.encode(ids.toList()));
  }

  Set<String> getBookmarkIds() {
    final raw = _bookmarks.get('ids');
    if (raw == null) return {};
    return (json.decode(raw) as List<dynamic>).map((e) => e as String).toSet();
  }

  Future<void> addOutboxEntry(OutboxEntry entry) async {
    await _outbox.put(entry.idempotencyKey, json.encode(entry.toStorageJson()));
  }

  Future<void> removeOutboxEntry(String idempotencyKey) async {
    await _outbox.delete(idempotencyKey);
  }

  List<OutboxEntry> getOutboxEntries() {
    return _outbox.values
        .map((raw) => OutboxEntry.fromJson(json.decode(raw) as Map<String, dynamic>))
        .toList();
  }

  Stream<int> watchOutboxCount() => _outbox.watchLength();

  Future<void> clearOutbox() async {
    await _outbox.clear();
  }

  Future<void> setMeta(String key, String value) async {
    await _meta.put(key, value);
  }

  String? getMeta(String key) {
    return _meta.get(key);
  }

  DateTime? getLastSyncTime() {
    final raw = _meta.get('last_sync');
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setLastSyncTime(DateTime time) async {
    await _meta.put('last_sync', time.toIso8601String());
  }

  bool getOnboardingCompleted() {
    return _meta.get('onboarding_completed') == 'true';
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _meta.put('onboarding_completed', '$completed');
  }

  String? getThemeMode() => _meta.get('theme_mode');

  Future<void> setThemeMode(String mode) async {
    await _meta.put('theme_mode', mode);
  }

  List<String> getSelectedTopicIds() => _getMetaList('selected_topics');

  Future<void> setSelectedTopicIds(List<String> ids) async {
    await _meta.put('selected_topics', json.encode(ids));
  }

  List<String> getRecentSearches() => _getMetaList('recent_searches');

  Future<void> setRecentSearches(List<String> queries) async {
    await _meta.put('recent_searches', json.encode(queries));
  }

  /// Client-side like overrides (B1) — restored on launch so the feed
  /// shows the correct liked state before the network answers.
  Map<String, dynamic> getReactionOverrides() {
    final raw = _meta.get('reaction_overrides');
    if (raw == null) return {};
    return Map<String, dynamic>.from(json.decode(raw) as Map);
  }

  Future<void> saveReactionOverride(String articleId, Map<String, dynamic> override) async {
    final all = getReactionOverrides();
    all[articleId] = override;
    await _meta.put('reaction_overrides', json.encode(all));
  }

  List<String> _getMetaList(String key) {
    final raw = _meta.get(key);
    if (raw == null) return [];
    return (json.decode(raw) as List<dynamic>).map((e) => e as String).toList();
  }
}
