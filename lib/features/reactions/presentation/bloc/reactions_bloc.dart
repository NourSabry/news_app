import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/article_overrides.dart';
import '../../domain/reaction_result.dart';
import '../../domain/reactions_repository.dart';
import 'reactions_event.dart';
import 'reactions_state.dart';

export '../../domain/article_overrides.dart';
export 'reactions_event.dart';
export 'reactions_state.dart';

class ReactionsBloc extends Bloc<ReactionsEvent, ReactionsState> {
  static const conflictMessage = 'Updated to latest';

  final ReactionsRepository _repository;

  ReactionsBloc(this._repository) : super(const ReactionsState()) {
    on<ToggleLike>(_onToggleLike);
  }

  Future<void> _onToggleLike(ToggleLike event, Emitter<ReactionsState> emit) async {
    final article = event.article;
    final liked = !article.isLiked;
    final optimistic = ArticleOverrides(
      isLiked: liked,
      likes: article.likes + (liked ? 1 : -1),
      version: article.version,
    );
    emit(state.withOverride(article.id, optimistic, notice: null));

    final result = await _repository.toggleLike(
      article.id,
      expectedVersion: event.expectedVersion,
    );
    switch (result) {
      case ReactionApplied(:final likes, :final version):
        final applied = ArticleOverrides(isLiked: liked, likes: likes, version: version);
        emit(state.withOverride(article.id, applied));
      case ReactionConflict(:final serverState):
        emit(state.withOverride(article.id, serverState, notice: conflictMessage));
      case ReactionQueued():
        break;
    }
  }
}
