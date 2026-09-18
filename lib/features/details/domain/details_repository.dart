import '../../../core/models/models.dart';

abstract class DetailsRepository {
  Article? getCachedArticle(String id);

  Future<ArticleResult> fetchArticle(String id);

  Future<List<Article>> fetchRelated(List<String> ids);

  Future<List<Topic>> getTopics();

  /// Last successful sync with the server — the age shown in the
  /// "Saved copy · Xh ago" caption when [getCachedArticle] served the read.
  DateTime? getLastSyncTime();
}
