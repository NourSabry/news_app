import '../../../core/models/models.dart';

class FeedDelta {
  final List<Article> newArticles;
  final List<Article> updatedArticles;
  final List<String> deletedIds;

  const FeedDelta({
    this.newArticles = const [],
    this.updatedArticles = const [],
    this.deletedIds = const [],
  });

  bool get isEmpty => newArticles.isEmpty && updatedArticles.isEmpty && deletedIds.isEmpty;
}
