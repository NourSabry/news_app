import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';
import '../../domain/article_overrides.dart';

const _unset = Object();

class ReactionsState extends Equatable {
  final Map<String, ArticleOverrides> overrides;

  /// Article ids with a toggle currently in flight — further taps on
  /// the same article are ignored while it's in this set.
  final Set<String> inFlight;

  final String? notice;

  /// Set alongside [notice] only when the notice is a rollback that offers
  /// a Retry action, so the listener showing the snackbar knows which
  /// article (and version) to retry.
  final Article? retryArticle;

  const ReactionsState({
    this.overrides = const {},
    this.inFlight = const {},
    this.notice,
    this.retryArticle,
  });

  Article apply(Article article) => article.applying(overrides[article.id]);

  bool isInFlight(String articleId) => inFlight.contains(articleId);

  /// [value] of null removes the override entirely — used to roll back to
  /// "no override" when a toggle fails and there was nothing to revert to.
  ReactionsState withOverride(
    String articleId,
    ArticleOverrides? value, {
    Object? notice = _unset,
    Object? retryArticle = _unset,
  }) {
    final nextOverrides = {...overrides};
    if (value == null) {
      nextOverrides.remove(articleId);
    } else {
      nextOverrides[articleId] = value;
    }
    return ReactionsState(
      overrides: nextOverrides,
      inFlight: inFlight,
      notice: identical(notice, _unset) ? this.notice : notice as String?,
      retryArticle: identical(retryArticle, _unset)
          ? this.retryArticle
          : retryArticle as Article?,
    );
  }

  ReactionsState withInFlight(String articleId, bool value) {
    final nextInFlight = {...inFlight};
    value ? nextInFlight.add(articleId) : nextInFlight.remove(articleId);
    return ReactionsState(
      overrides: overrides,
      inFlight: nextInFlight,
      notice: notice,
      retryArticle: retryArticle,
    );
  }

  @override
  List<Object?> get props => [overrides, inFlight, notice, retryArticle];
}
