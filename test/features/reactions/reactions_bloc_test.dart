import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/features/reactions/domain/reaction_result.dart';
import 'package:news_app/features/reactions/domain/reactions_repository.dart';
import 'package:news_app/features/reactions/presentation/bloc/reactions_bloc.dart';

class MockReactionsRepository extends Mock implements ReactionsRepository {}

Article article({bool isLiked = false, int likes = 10, int version = 1}) => Article(
      id: 'a',
      title: 'Title',
      summary: 'Summary',
      source: 'Source',
      author: const Author(id: 'u', name: 'Author'),
      topicId: 't_technology',
      publishedAt: DateTime(2026, 9, 14),
      isLiked: isLiked,
      likes: likes,
      version: version,
    );

ReactionsState overridden({
  required bool isLiked,
  required int likes,
  required int version,
  String? notice,
  bool inFlight = false,
  Article? retryArticle,
}) {
  return ReactionsState(
    overrides: {'a': ArticleOverrides(isLiked: isLiked, likes: likes, version: version)},
    inFlight: inFlight ? const {'a'} : const {},
    notice: notice,
    retryArticle: retryArticle,
  );
}

void main() {
  late MockReactionsRepository repository;

  setUpAll(() {
    registerFallbackValue(const ArticleOverrides(isLiked: false, likes: 0, version: 1));
  });

  setUp(() {
    repository = MockReactionsRepository();
    when(() => repository.loadPersistedOverrides()).thenReturn({});
    when(() => repository.persistOverride(any(), any())).thenAnswer((_) async {});
  });

  test('starts from overrides persisted by a previous session (B1)', () {
    when(() => repository.loadPersistedOverrides()).thenReturn({
      'a': const ArticleOverrides(isLiked: true, likes: 11, version: 1),
    });

    final bloc = ReactionsBloc(repository);

    expect(bloc.state.overrides, {'a': const ArticleOverrides(isLiked: true, likes: 11, version: 1)});
  });

  blocTest<ReactionsBloc, ReactionsState>(
    'likes optimistically and then applies the server count and version',
    build: () {
      when(() => repository.toggleLike('a', expectedVersion: 1))
          .thenAnswer((_) async => const ReactionApplied(likes: 12, version: 2));
      return ReactionsBloc(repository);
    },
    act: (bloc) => bloc.add(ToggleLike(article())),
    expect: () => [
      overridden(isLiked: true, likes: 11, version: 1, inFlight: true),
      overridden(isLiked: true, likes: 12, version: 2),
    ],
  );

  blocTest<ReactionsBloc, ReactionsState>(
    'unlikes optimistically when the article is already liked',
    build: () {
      when(() => repository.toggleLike('a', expectedVersion: 3))
          .thenAnswer((_) async => const ReactionApplied(likes: 9, version: 4));
      return ReactionsBloc(repository);
    },
    act: (bloc) => bloc.add(ToggleLike(article(isLiked: true, version: 3))),
    expect: () => [
      overridden(isLiked: false, likes: 9, version: 3, inFlight: true),
      overridden(isLiked: false, likes: 9, version: 4),
    ],
  );

  blocTest<ReactionsBloc, ReactionsState>(
    'replaces the article with the server state and notices on conflict',
    build: () {
      when(() => repository.toggleLike('a', expectedVersion: 1)).thenAnswer(
        (_) async => const ReactionConflict(
          ArticleOverrides(isLiked: true, likes: 186, version: 3),
        ),
      );
      return ReactionsBloc(repository);
    },
    act: (bloc) => bloc.add(ToggleLike(article())),
    expect: () => [
      overridden(isLiked: true, likes: 11, version: 1, inFlight: true),
      overridden(isLiked: true, likes: 186, version: 3, notice: ReactionsBloc.conflictMessage),
    ],
  );

  blocTest<ReactionsBloc, ReactionsState>(
    'keeps the optimistic state when the change is queued offline',
    build: () {
      when(() => repository.toggleLike('a', expectedVersion: 1))
          .thenAnswer((_) async => const ReactionQueued());
      return ReactionsBloc(repository);
    },
    act: (bloc) => bloc.add(ToggleLike(article())),
    expect: () => [
      overridden(isLiked: true, likes: 11, version: 1, inFlight: true),
      overridden(isLiked: true, likes: 11, version: 1),
    ],
  );

  blocTest<ReactionsBloc, ReactionsState>(
    'clears a previous notice when a new toggle starts',
    build: () {
      when(() => repository.toggleLike('a', expectedVersion: 3))
          .thenAnswer((_) async => const ReactionQueued());
      return ReactionsBloc(repository);
    },
    seed: () => overridden(isLiked: true, likes: 186, version: 3, notice: ReactionsBloc.conflictMessage),
    act: (bloc) => bloc.add(ToggleLike(article(isLiked: true, likes: 186, version: 3))),
    expect: () => [
      overridden(isLiked: false, likes: 185, version: 3, inFlight: true),
      overridden(isLiked: false, likes: 185, version: 3),
    ],
  );

  blocTest<ReactionsBloc, ReactionsState>(
    'rolls back to no override on a server rejection and offers Retry (G2)',
    build: () {
      when(() => repository.toggleLike('a', expectedVersion: 1))
          .thenAnswer((_) async => const ReactionFailed('Reaction was not saved'));
      return ReactionsBloc(repository);
    },
    act: (bloc) => bloc.add(ToggleLike(article())),
    expect: () => [
      overridden(isLiked: true, likes: 11, version: 1, inFlight: true),
      ReactionsState(
        overrides: const {},
        notice: 'Reaction was not saved',
        retryArticle: article(),
      ),
    ],
  );

  blocTest<ReactionsBloc, ReactionsState>(
    'rolls back to the previous override (not "no override") on rejection (G2)',
    build: () {
      when(() => repository.toggleLike('a', expectedVersion: 3))
          .thenAnswer((_) async => const ReactionFailed('Reaction was not saved'));
      return ReactionsBloc(repository);
    },
    seed: () => overridden(isLiked: true, likes: 186, version: 3),
    act: (bloc) => bloc.add(ToggleLike(article(isLiked: true, likes: 186, version: 3))),
    expect: () => [
      overridden(isLiked: false, likes: 185, version: 3, inFlight: true),
      overridden(
        isLiked: true,
        likes: 186,
        version: 3,
        notice: 'Reaction was not saved',
        retryArticle: article(isLiked: true, likes: 186, version: 3),
      ),
    ],
  );

  blocTest<ReactionsBloc, ReactionsState>(
    'ignores a second tap on the same article while one is in flight (G2)',
    build: () {
      when(() => repository.toggleLike('a', expectedVersion: 1)).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 20),
          () => const ReactionApplied(likes: 12, version: 2),
        ),
      );
      return ReactionsBloc(repository);
    },
    act: (bloc) => bloc
      ..add(ToggleLike(article()))
      ..add(ToggleLike(article())),
    wait: const Duration(milliseconds: 50),
    expect: () => [
      overridden(isLiked: true, likes: 11, version: 1, inFlight: true),
      overridden(isLiked: true, likes: 12, version: 2),
    ],
    verify: (_) => verify(() => repository.toggleLike('a', expectedVersion: 1)).called(1),
  );
}
