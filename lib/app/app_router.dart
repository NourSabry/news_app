/// Parsed deep-link destinations. Kept deliberately small — no full
/// router package needed for one destination type.
sealed class AppRoute {
  const AppRoute();
}

class ArticleRoute extends AppRoute {
  final String articleId;

  const ArticleRoute(this.articleId);

  @override
  bool operator ==(Object other) =>
      other is ArticleRoute && other.articleId == articleId;

  @override
  int get hashCode => articleId.hashCode;
}

/// Recognises `newsfeed://article/{id}` and `https://newsfeed.app/article/{id}`
///. Anything else — wrong scheme/host, no id, unparseable — is
/// "malformed" and returns null; the caller falls back to feed + a snackbar.
class AppRouter {
  AppRouter._();

  /// The `https://` form of a deep link — the `newsfeed://`
  /// form only round-trips inside the app.
  static Uri articleShareLink(String articleId) =>
      Uri.https('newsfeed.app', '/article/$articleId');

  static AppRoute? parse(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) return null;

    if (uri.scheme == 'newsfeed' && uri.host == 'article') {
      return _articleRouteFor(
        uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null,
      );
    }

    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host == 'newsfeed.app') {
      final segments = uri.pathSegments;
      if (segments.length >= 2 && segments.first == 'article') {
        return _articleRouteFor(segments[1]);
      }
    }

    return null;
  }

  static ArticleRoute? _articleRouteFor(String? id) {
    if (id == null || id.isEmpty) return null;
    return ArticleRoute(id);
  }
}
