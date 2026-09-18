import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/models/models.dart';
import '../features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import '../features/reactions/presentation/bloc/reactions_bloc.dart';

extension ArticleSync on BuildContext {
  Article liveArticle(Article article) {
    final overrides = select<ReactionsBloc, ArticleOverrides?>(
      (bloc) => bloc.state.overrides[article.id],
    );
    final isBookmarked = select<BookmarksBloc, bool>(
      (bloc) => bloc.state.contains(article.id),
    );
    return article.applying(overrides).copyWith(isBookmarked: isBookmarked);
  }

  bool isLikeInFlight(String articleId) {
    return select<ReactionsBloc, bool>(
      (bloc) => bloc.state.isInFlight(articleId),
    );
  }

  void toggleLike(Article article) =>
      read<ReactionsBloc>().add(ToggleLike(article));

  void toggleBookmark(Article article) =>
      read<BookmarksBloc>().add(ToggleBookmark(article));
}
