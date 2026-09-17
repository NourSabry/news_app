import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/future_extensions.dart';
import '../../domain/details_repository.dart';
import 'details_event.dart';
import 'details_state.dart';

export 'details_event.dart';
export 'details_state.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  static const loadErrorMessage = "Couldn't load this story";

  final DetailsRepository _repository;

  DetailsBloc(this._repository, Article article) : super(DetailsState(article: article)) {
    on<LoadArticle>(_onLoad);
  }

  Future<void> _onLoad(LoadArticle event, Emitter<DetailsState> emit) async {
    final cached = _repository.getCachedArticle(state.article.id);
    emit(state.copyWith(
      article: cached ?? state.article,
      isLoading: true,
      fromCache: cached != null,
      lastSyncedAt: cached != null ? _repository.getLastSyncTime() : null,
      errorMessage: null,
      unavailableReason: null,
    ));
    try {
      final (result, topics) = await (
        _repository.fetchArticle(state.article.id),
        _repository.getTopics().orFallback(state.topics),
      ).wait;
      switch (result) {
        case ArticleFound(:final article):
          emit(state.copyWith(article: article, topics: topics, isLoading: false, fromCache: false));
        case ArticleUnavailable(:final reason):
          emit(state.copyWith(
            topics: topics,
            isLoading: false,
            fromCache: false,
            unavailableReason: reason,
          ));
      }
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: state.hasBody ? null : loadErrorMessage,
      ));
    }
    if (!state.isUnavailable) await _loadRelated(emit);
  }

  Future<void> _loadRelated(Emitter<DetailsState> emit) async {
    final ids = state.article.related ?? const [];
    if (ids.isEmpty) return;
    final related = await _repository.fetchRelated(ids);
    if (related.isNotEmpty) emit(state.copyWith(related: related));
  }
}
