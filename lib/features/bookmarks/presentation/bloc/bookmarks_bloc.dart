import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/future_extensions.dart';
import '../../domain/bookmarks_repository.dart';
import 'bookmarks_event.dart';
import 'bookmarks_state.dart';

export 'bookmarks_event.dart';
export 'bookmarks_state.dart';

class BookmarksBloc extends Bloc<BookmarksEvent, BookmarksState> {
  final BookmarksRepository _repository;

  BookmarksBloc(this._repository) : super(const BookmarksState()) {
    on<LoadBookmarks>(_onLoad);
    on<ToggleBookmark>(_onToggle);
  }

  Future<void> _onLoad(LoadBookmarks event, Emitter<BookmarksState> emit) async {
    final localIds = _repository.getIds();
    emit(state.copyWith(ids: localIds, isLoading: true));

    final (ids, topics) = await (
      _repository.reconcileIds().orFallback(localIds),
      _repository.getTopics().orFallback(state.topics),
    ).wait;
    final articles = await _repository.getArticles(ids);
    emit(state.copyWith(ids: ids, articles: articles, topics: topics, isLoading: false));
  }

  Future<void> _onToggle(ToggleBookmark event, Emitter<BookmarksState> emit) async {
    final article = event.article;
    final bookmarked = !state.contains(article.id);
    final ids = {...state.ids};
    bookmarked ? ids.add(article.id) : ids.remove(article.id);
    final articles = bookmarked
        ? [article, ...state.articles]
        : state.articles.where((a) => a.id != article.id).toList();
    emit(state.copyWith(ids: ids, articles: articles));
    await _repository.setBookmark(article, bookmarked: bookmarked);
  }
}
