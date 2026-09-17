import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';
import '../../domain/article_overrides.dart';

sealed class ReactionsEvent extends Equatable {
  const ReactionsEvent();

  @override
  List<Object?> get props => [];
}

class ToggleLike extends ReactionsEvent {
  final Article article;

  const ToggleLike(this.article);

  String get articleId => article.id;
  int get expectedVersion => article.version;

  @override
  List<Object?> get props => [article];
}

/// Enacts an outbox sync conflict's only resolution — "keep server" (X1) —
/// by writing the server's state straight into overrides, the same as an
/// online conflict already does inside `_onToggleLike`.
class ApplyOverride extends ReactionsEvent {
  final String articleId;
  final ArticleOverrides value;

  const ApplyOverride(this.articleId, this.value);

  @override
  List<Object?> get props => [articleId, value];
}
