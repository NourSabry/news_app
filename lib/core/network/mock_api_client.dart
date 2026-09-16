import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'api_client.dart';

class MockApiClient implements ApiClient {
  List<Article>? _cachedArticles;
  List<Topic>? _cachedTopics;
  Map<String, List<String>>? _cachedSources;

  bool simulateOffline = false;
  bool simulateError = false;
  bool simulateConflict = false;
  int _latencyMs = 400;

  set latencyMs(int value) => _latencyMs = value;

  Future<void> _simulateNetwork() async {
    if (simulateOffline) {
      throw Exception('No internet connection');
    }
    await Future.delayed(Duration(milliseconds: _latencyMs + Random().nextInt(200)));
    if (simulateError) {
      throw Exception('Server error');
    }
  }

  Future<List<Article>> _loadArticles() async {
    if (_cachedArticles != null) return _cachedArticles!;
    final jsonString = await rootBundle.loadString('assets/mock/articles.json');
    final jsonList = json.decode(jsonString) as List<dynamic>;
    _cachedArticles = jsonList
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cachedArticles!;
  }

  Future<List<Topic>> _loadTopics() async {
    if (_cachedTopics != null) return _cachedTopics!;
    final jsonString = await rootBundle.loadString('assets/mock/topics.json');
    final jsonList = json.decode(jsonString) as List<dynamic>;
    _cachedTopics = jsonList
        .map((e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cachedTopics!;
  }

  Future<Map<String, List<String>>> _loadSources() async {
    if (_cachedSources != null) return _cachedSources!;
    final jsonString = await rootBundle.loadString('assets/mock/sources.json');
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    _cachedSources = jsonMap.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).map((e) => e as String).toList(),
      ),
    );
    return _cachedSources!;
  }

  @override
  Future<List<Topic>> getTopics() async {
    await _simulateNetwork();
    return _loadTopics();
  }

  @override
  Future<Map<String, List<String>>> getSources({String? topicId}) async {
    await _simulateNetwork();
    final allSources = await _loadSources();
    if (topicId != null) {
      return {topicId: allSources[topicId] ?? []};
    }
    return allSources;
  }

  @override
  Future<FeedResponse> getFeed({
    int page = 1,
    int pageSize = 10,
    String? topic,
    String? source,
    String? cursor,
  }) async {
    await _simulateNetwork();
    final articles = await _loadArticles();

    var filtered = articles.toList();
    if (topic != null && topic.isNotEmpty) {
      filtered = filtered.where((a) => a.topicId == topic).toList();
    }
    if (source != null && source.isNotEmpty) {
      filtered = filtered.where((a) => a.source == source).toList();
    }

    filtered.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    final actualPage = cursor != null
        ? int.tryParse(cursor.replaceAll('feed_', '')) ?? page
        : page;

    final startIndex = (actualPage - 1) * pageSize;
    final endIndex = min(startIndex + pageSize, filtered.length);
    final pageData = startIndex < filtered.length
        ? filtered.sublist(startIndex, endIndex)
        : <Article>[];

    final hasMore = endIndex < filtered.length;

    return FeedResponse(
      data: pageData,
      page: actualPage,
      pageSize: pageSize,
      total: filtered.length,
      nextCursor: hasMore ? 'feed_${actualPage + 1}' : null,
    );
  }

  @override
  Future<Article> getArticle(String id) async {
    await _simulateNetwork();
    final articles = await _loadArticles();
    return articles.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception('Article not found: $id'),
    );
  }

  @override
  Future<FeedResponse> search({
    required String query,
    int page = 1,
    int pageSize = 10,
    String? topic,
    String? source,
  }) async {
    await _simulateNetwork();
    final articles = await _loadArticles();
    final lowerQuery = query.toLowerCase();

    final filtered = articles.where((a) {
      final matchesQuery = a.title.toLowerCase().contains(lowerQuery) ||
          a.summary.toLowerCase().contains(lowerQuery) ||
          a.tags.any((t) => t.toLowerCase().contains(lowerQuery));
      final matchesTopic = topic == null || topic.isEmpty || a.topicId == topic;
      final matchesSource = source == null || source.isEmpty || a.source == source;
      return matchesQuery && matchesTopic && matchesSource;
    }).toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    final startIndex = (page - 1) * pageSize;
    final endIndex = min(startIndex + pageSize, filtered.length);
    final pageData = startIndex < filtered.length
        ? filtered.sublist(startIndex, endIndex)
        : <Article>[];

    return FeedResponse(
      data: pageData,
      page: page,
      pageSize: pageSize,
      total: filtered.length,
      nextCursor: endIndex < filtered.length ? 'search_${page + 1}' : null,
    );
  }

  @override
  Future<List<String>> getSuggestions(String query) async {
    await _simulateNetwork();
    final articles = await _loadArticles();
    final lowerQuery = query.toLowerCase();

    final allTags = articles.expand((a) => a.tags).toSet();
    final allTitles = articles.map((a) => a.title).toSet();

    final suggestions = <String>{};
    for (final tag in allTags) {
      if (tag.toLowerCase().contains(lowerQuery)) {
        suggestions.add(tag);
      }
    }
    for (final title in allTitles) {
      if (title.toLowerCase().contains(lowerQuery)) {
        suggestions.add(title);
      }
      if (suggestions.length >= 5) break;
    }

    return suggestions.take(5).toList();
  }

  @override
  Future<Map<String, dynamic>> toggleReaction({
    required String articleId,
    required String reaction,
    required String clientMutationId,
    required int expectedVersion,
  }) async {
    await _simulateNetwork();

    if (simulateConflict) {
      return {
        'status': 'conflict',
        'articleId': articleId,
        'serverState': {'isLiked': true, 'likes': 186, 'version': expectedVersion + 2},
      };
    }

    final articles = await _loadArticles();
    final article = articles.firstWhere((a) => a.id == articleId);
    final newLiked = !article.isLiked;

    return {
      'status': 'success',
      'articleId': articleId,
      'reaction': reaction,
      'likes': article.likes + (newLiked ? 1 : -1),
      'version': expectedVersion + 1,
    };
  }

  @override
  Future<void> setBookmark({
    required String articleId,
    required bool bookmarked,
  }) async {
    await _simulateNetwork();
  }

  @override
  Future<List<String>> getBookmarkIds() async {
    await _simulateNetwork();
    return ['a_flutter_roadmap', 'a_startup_funding'];
  }

  @override
  Future<FeedUpdate> getFeedUpdates(DateTime since) async {
    await _simulateNetwork();
    return FeedUpdate(
      newItems: ['a_ai_policy'],
      updatedItems: ['a_flutter_roadmap'],
      deletedItems: [],
      serverTime: DateTime.now(),
    );
  }

  @override
  Future<Map<String, dynamic>> syncOutbox({
    required int baseVersion,
    required List<OutboxEntry> mutations,
  }) async {
    await _simulateNetwork();
    return {
      'status': 'success',
      'newVersion': baseVersion + 1,
      'applied': mutations.map((m) => m.idempotencyKey).toList(),
      'conflicts': <Map<String, dynamic>>[],
    };
  }

  @override
  Future<Map<String, dynamic>> getFlags() async {
    await _simulateNetwork();
    return {
      'enableReactions': true,
      'enableBookmarks': true,
      'enableOfflineOutbox': true,
      'searchDebounceMs': 400,
      'feedPageSize': 10,
      'cacheTtlMinutes': 30,
      'showTrendingTopics': true,
      'maintenanceMode': false,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getTrending() async {
    await _simulateNetwork();
    return [
      {'label': 'Flutter', 'articleCount': 18},
      {'label': 'Clean Energy', 'articleCount': 12},
      {'label': 'Markets', 'articleCount': 9},
      {'label': 'AI Policy', 'articleCount': 7},
      {'label': 'Tennis', 'articleCount': 6},
    ];
  }
}
