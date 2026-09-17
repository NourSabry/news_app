import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'api_client.dart';

class MockApiClient implements ApiClient {
  List<Article>? _cachedArticles;
  List<Topic>? _cachedTopics;
  Map<String, List<String>>? _cachedSources;
  final Set<String> _bookmarkIds = {'a_flutter_roadmap', 'a_startup_funding'};

  bool simulateOffline = false;
  bool simulateError = false;
  bool simulateConflict = false;
  int _latencyMs = 400;
  int _refreshCount = 0;

  static const _breakingHeadlines = [
    'Breaking: Major Tech Conference Announces Surprise Keynote',
    'Breaking: Central Bank Signals Rate Decision Ahead of Schedule',
    'Breaking: Championship Final Rescheduled After Weather Delay',
  ];

  set latencyMs(int value) => _latencyMs = value;

  Future<void> _simulateNetwork() async {
    if (simulateOffline) {
      throw Exception('No internet connection');
    }
    if (_latencyMs > 0) {
      await Future.delayed(Duration(milliseconds: _latencyMs + Random().nextInt(200)));
    }
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
    List<String> topics = const [],
    String? source,
    String? cursor,
  }) async {
    await _simulateNetwork();
    final articles = await _loadArticles();

    var filtered = articles.toList();
    if (topics.isNotEmpty) {
      filtered = filtered.where((a) => topics.contains(a.topicId)).toList();
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

    final article = await _toggleLike(articleId, expectedVersion);
    return {
      'status': 'success',
      'articleId': articleId,
      'reaction': reaction,
      'likes': article.likes,
      'version': article.version,
    };
  }

  Future<Article> _toggleLike(String articleId, int expectedVersion) async {
    final articles = await _loadArticles();
    final index = articles.indexWhere((a) => a.id == articleId);
    final article = articles[index];
    final liked = !article.isLiked;
    return articles[index] = article.copyWith(
      isLiked: liked,
      likes: article.likes + (liked ? 1 : -1),
      version: expectedVersion + 1,
    );
  }

  @override
  Future<void> setBookmark({
    required String articleId,
    required bool bookmarked,
  }) async {
    await _simulateNetwork();
    _setBookmark(articleId, bookmarked);
  }

  void _setBookmark(String articleId, bool bookmarked) {
    bookmarked ? _bookmarkIds.add(articleId) : _bookmarkIds.remove(articleId);
  }

  @override
  Future<List<String>> getBookmarkIds() async {
    await _simulateNetwork();
    return _bookmarkIds.toList();
  }

  @override
  Future<FeedUpdate> getFeedUpdates(DateTime since) async {
    await _simulateNetwork();
    final articles = await _loadArticles();
    final fresh = _createBreakingArticle(articles.first);
    articles.insert(0, fresh);
    _bumpEngagement(articles, 'a_flutter_roadmap');
    return FeedUpdate(
      newItems: [fresh.id],
      updatedItems: ['a_flutter_roadmap'],
      deletedItems: [],
      serverTime: DateTime.now(),
    );
  }

  Article _createBreakingArticle(Article template) {
    final index = _refreshCount++;
    return template.copyWith(
      id: 'a_breaking_$index',
      title: _breakingHeadlines[index % _breakingHeadlines.length],
      summary: 'Developing story. Details are being updated as they come in.',
      image: 'https://picsum.photos/seed/breaking-$index/900/600',
      publishedAt: DateTime.now(),
      updatedAt: null,
      likes: 0,
      comments: 0,
      isLiked: false,
      isBookmarked: false,
      version: 1,
    );
  }

  void _bumpEngagement(List<Article> articles, String id) {
    final index = articles.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final article = articles[index];
    articles[index] = article.copyWith(
      likes: article.likes + 3,
      comments: article.comments + 1,
      version: article.version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Map<String, dynamic>> syncOutbox({
    required int baseVersion,
    required List<OutboxEntry> mutations,
  }) async {
    await _simulateNetwork();
    for (final mutation in mutations) {
      await _applyMutation(mutation);
    }
    return {
      'status': 'success',
      'newVersion': baseVersion + 1,
      'applied': mutations.map((m) => m.idempotencyKey).toList(),
      'conflicts': <Map<String, dynamic>>[],
    };
  }

  Future<void> _applyMutation(OutboxEntry entry) async {
    final articleId = entry.payload['articleId'] as String;
    switch (entry.operation) {
      case OutboxOperation.toggleReaction:
        await _toggleLike(articleId, entry.payload['expectedVersion'] as int);
      case OutboxOperation.setBookmark:
        _setBookmark(articleId, entry.payload['bookmarked'] as bool);
    }
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
