import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';
import '../../domain/article_overrides.dart';

const _unset = Object();

class ReactionsState extends Equatable {
  final Map<String, ArticleOverrides> overrides;
  final String? notice;

  const ReactionsState({this.overrides = const {}, this.notice});

  Article apply(Article article) => article.applying(overrides[article.id]);

  ReactionsState withOverride(
    String articleId,
    ArticleOverrides value, {
    Object? notice = _unset,
  }) {
    return ReactionsState(
      overrides: {...overrides, articleId: value},
      notice: identical(notice, _unset) ? this.notice : notice as String?,
    );
  }

  @override
  List<Object?> get props => [overrides, notice];
}
