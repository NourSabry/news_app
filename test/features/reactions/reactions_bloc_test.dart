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

ReactionsState overridden({required bool isLiked, required int likes, required int version, String? notice}) {
  return ReactionsState(
    overrides: {'a': ArticleOverrides(isLiked: isLiked, likes: likes, version: version)},
    notice: notice,
  );
}

void main() {
  late MockReactionsRepository repository;

  setUp(() => repository = MockReactionsRepository());

  blocTest<ReactionsBloc, ReactionsState>(
    'likes optimistically and then applies the server count and version',
    build: () {
      when(() => repository.toggleLike('a', expectedVersion: 1))
          .thenAnswer((_) async => const ReactionApplied(likes: 12, version: 2));
      return ReactionsBloc(repository);
    },
    act: (bloc) => bloc.add(ToggleLike(article())),
    expect: () => [
      overridden(isLiked: true, likes: 11, version: 1),
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
      overridden(isLiked: false, likes: 9, version: 3),
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
      overridden(isLiked: true, likes: 11, version: 1),
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
    expect: () => [overridden(isLiked: true, likes: 11, version: 1)],
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
    expect: () => [overridden(isLiked: false, likes: 185, version: 3)],
  );
}
