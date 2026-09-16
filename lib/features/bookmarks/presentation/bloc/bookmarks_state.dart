import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';

class BookmarksState extends Equatable {
  final Set<String> ids;
  final List<Article> articles;
  final List<Topic> topics;
  final bool isLoading;

  const BookmarksState({
    this.ids = const {},
    this.articles = const [],
    this.topics = const [],
    this.isLoading = false,
  });

  bool contains(String articleId) => ids.contains(articleId);
  bool get isEmpty => articles.isEmpty;

  String topicNameFor(String topicId) => topics.nameFor(topicId);

  BookmarksState copyWith({
    Set<String>? ids,
    List<Article>? articles,
    List<Topic>? topics,
    bool? isLoading,
  }) {
    return BookmarksState(
      ids: ids ?? this.ids,
      articles: articles ?? this.articles,
      topics: topics ?? this.topics,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [ids, articles, topics, isLoading];
}
