import '../../../core/models/models.dart';

abstract class BookmarksRepository {
  Set<String> getIds();

  Future<Set<String>> reconcileIds();

  Future<void> setBookmark(Article article, {required bool bookmarked});

  Future<List<Article>> getArticles(Iterable<String> ids);

  Future<List<Topic>> getTopics();
}
