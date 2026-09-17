import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/outbox/domain/outbox_conflict.dart';
import 'package:news_app/features/outbox/presentation/widgets/conflict_review_sheet.dart';

void main() {
  testWidgets('shows the article title and server state per conflict (X1)', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => ConflictReviewSheet.show(context, const [
              OutboxConflict(
                articleId: 'a_flutter_roadmap',
                articleTitle: 'Flutter Roadmap',
                serverIsLiked: true,
                serverLikes: 186,
                serverVersion: 5,
              ),
            ]),
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('1 change was updated'), findsOneWidget);
    expect(find.textContaining('Flutter Roadmap'), findsOneWidget);
    expect(
      find.textContaining('it now has 186 likes and is already liked'),
      findsOneWidget,
    );
    expect(find.text('Keep server'), findsOneWidget);

    await tester.tap(find.text('Keep server'));
    await tester.pumpAndSettle();
    expect(find.byType(ConflictReviewSheet), findsNothing);
  });

  testWidgets('phrases an unlike conflict distinctly (X1)', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => ConflictReviewSheet.show(context, const [
              OutboxConflict(
                articleId: 'a',
                articleTitle: 'Some Story',
                serverIsLiked: false,
                serverLikes: 40,
                serverVersion: 2,
              ),
            ]),
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('You unliked'), findsOneWidget);
    expect(find.textContaining('is no longer liked'), findsOneWidget);
  });
}
