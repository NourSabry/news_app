import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';

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
