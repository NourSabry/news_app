import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';

enum FeedStatus { initial, loading, success, failure }

const _unset = Object();

class FeedState extends Equatable {
  final FeedStatus status;
  final List<Article> articles;
  final List<Article> pendingArticles;
  final List<Topic> topics;
  final List<TrendingTopic> trending;
  final List<String> selectedTopicIds;
  final DateTime? lastSyncedAt;
  final String? nextCursor;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? errorMessage;
  final String? notice;

  const FeedState({
    this.status = FeedStatus.initial,
    this.articles = const [],
    this.pendingArticles = const [],
    this.topics = const [],
    this.trending = const [],
    this.selectedTopicIds = const [],
    this.lastSyncedAt,
    this.nextCursor,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.notice,
  });

  bool get hasMore => nextCursor != null;
  bool get isEmpty => articles.isEmpty;
  bool get hasPending => pendingArticles.isNotEmpty;

  String topicNameFor(String topicId) => topics.nameFor(topicId);

  FeedState copyWith({
    FeedStatus? status,
    List<Article>? articles,
    List<Article>? pendingArticles,
    List<Topic>? topics,
    List<TrendingTopic>? trending,
    List<String>? selectedTopicIds,
    Object? lastSyncedAt = _unset,
    Object? nextCursor = _unset,
    bool? isLoadingMore,
    bool? isRefreshing,
    Object? errorMessage = _unset,
    Object? notice = _unset,
  }) {
    return FeedState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      pendingArticles: pendingArticles ?? this.pendingArticles,
      topics: topics ?? this.topics,
      trending: trending ?? this.trending,
      selectedTopicIds: selectedTopicIds ?? this.selectedTopicIds,
      lastSyncedAt: identical(lastSyncedAt, _unset) ? this.lastSyncedAt : lastSyncedAt as DateTime?,
      nextCursor: identical(nextCursor, _unset) ? this.nextCursor : nextCursor as String?,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      notice: identical(notice, _unset) ? this.notice : notice as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        articles,
        pendingArticles,
        topics,
        trending,
        selectedTopicIds,
        lastSyncedAt,
        nextCursor,
        isLoadingMore,
        isRefreshing,
        errorMessage,
        notice,
      ];
}
