import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';

const _unset = Object();

class DetailsState extends Equatable {
  final Article article;
  final List<Article> related;
  final List<Topic> topics;
  final bool isLoading;
  final bool fromCache;
  final String? errorMessage;

  const DetailsState({
    required this.article,
    this.related = const [],
    this.topics = const [],
    this.isLoading = false,
    this.fromCache = false,
    this.errorMessage,
  });

  bool get hasBody => article.body != null;
  String get topicName => topics.nameFor(article.topicId);

  DetailsState copyWith({
    Article? article,
    List<Article>? related,
    List<Topic>? topics,
    bool? isLoading,
    bool? fromCache,
    Object? errorMessage = _unset,
  }) {
    return DetailsState(
      article: article ?? this.article,
      related: related ?? this.related,
      topics: topics ?? this.topics,
      isLoading: isLoading ?? this.isLoading,
      fromCache: fromCache ?? this.fromCache,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [article, related, topics, isLoading, fromCache, errorMessage];
}
