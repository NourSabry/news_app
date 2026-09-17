import '../../../core/models/models.dart';

abstract class DetailsRepository {
  Article? getCachedArticle(String id);

  Future<ArticleResult> fetchArticle(String id);

  Future<List<Article>> fetchRelated(List<String> ids);

  Future<List<Topic>> getTopics();
}
