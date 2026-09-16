import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class LocalStorage {
  static const String _feedCacheBox = 'feed_cache';
  static const String _articlesBox = 'articles';
  static const String _bookmarksBox = 'bookmarks';
  static const String _outboxBox = 'outbox';
  static const String _metaBox = 'meta';

  late Box<String> _feedCache;
  late Box<String> _articles;
  late Box<String> _bookmarks;
  late Box<String> _outbox;
  late Box<String> _meta;

  Future<void> init() async {
    await Hive.initFlutter();
    _feedCache = await Hive.openBox<String>(_feedCacheBox);
    _articles = await Hive.openBox<String>(_articlesBox);
    _bookmarks = await Hive.openBox<String>(_bookmarksBox);
    _outbox = await Hive.openBox<String>(_outboxBox);
    _meta = await Hive.openBox<String>(_metaBox);
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

  Future<void> setOnboardingCompleted() async {
    await _meta.put('onboarding_completed', 'true');
  }

  List<String> getSelectedTopicIds() => _getMetaList('selected_topics');

  Future<void> setSelectedTopicIds(List<String> ids) async {
    await _meta.put('selected_topics', json.encode(ids));
  }

  List<String> getRecentSearches() => _getMetaList('recent_searches');

  Future<void> setRecentSearches(List<String> queries) async {
    await _meta.put('recent_searches', json.encode(queries));
  }

  List<String> _getMetaList(String key) {
    final raw = _meta.get(key);
    if (raw == null) return [];
    return (json.decode(raw) as List<dynamic>).map((e) => e as String).toList();
  }
}
