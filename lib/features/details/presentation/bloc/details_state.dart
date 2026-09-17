import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';

const _unset = Object();

class DetailsState extends Equatable {
  final Article article;
  final List<Article> related;
  final List<Topic> topics;
  final bool isLoading;
  final bool fromCache;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  /// Plain-language reason the publisher pulled this story (G3), or null
  /// while it's still available.
  final String? unavailableReason;

  const DetailsState({
    required this.article,
    this.related = const [],
    this.topics = const [],
    this.isLoading = false,
    this.fromCache = false,
    this.lastSyncedAt,
    this.errorMessage,
    this.unavailableReason,
  });

  bool get hasBody => article.body != null;
  bool get isUnavailable => unavailableReason != null;
  String get topicName => topics.nameFor(article.topicId);

  DetailsState copyWith({
    Article? article,
    List<Article>? related,
    List<Topic>? topics,
    bool? isLoading,
    bool? fromCache,
    Object? lastSyncedAt = _unset,
    Object? errorMessage = _unset,
    Object? unavailableReason = _unset,
  }) {
    return DetailsState(
      article: article ?? this.article,
      related: related ?? this.related,
      topics: topics ?? this.topics,
      isLoading: isLoading ?? this.isLoading,
      fromCache: fromCache ?? this.fromCache,
      lastSyncedAt:
          identical(lastSyncedAt, _unset) ? this.lastSyncedAt : lastSyncedAt as DateTime?,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      unavailableReason: identical(unavailableReason, _unset)
          ? this.unavailableReason
          : unavailableReason as String?,
    );
  }

  @override
  List<Object?> get props => [
        article,
        related,
        topics,
        isLoading,
        fromCache,
        lastSyncedAt,
        errorMessage,
        unavailableReason,
      ];
}
