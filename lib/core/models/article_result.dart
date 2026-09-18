import 'article.dart';

/// The result of fetching a single article: either the
/// article, or a plain-language reason it's gone (`removed_by_publisher`).
sealed class ArticleResult {
  const ArticleResult();
}

class ArticleFound extends ArticleResult {
  final Article article;

  const ArticleFound(this.article);
}

class ArticleUnavailable extends ArticleResult {
  final String reason;

  const ArticleUnavailable(this.reason);
}
