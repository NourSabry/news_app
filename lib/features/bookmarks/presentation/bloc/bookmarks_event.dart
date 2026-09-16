import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';

sealed class BookmarksEvent extends Equatable {
  const BookmarksEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookmarks extends BookmarksEvent {
  const LoadBookmarks();
}

class ToggleBookmark extends BookmarksEvent {
  final Article article;

  const ToggleBookmark(this.article);

  String get articleId => article.id;

  @override
  List<Object?> get props => [article];
}
