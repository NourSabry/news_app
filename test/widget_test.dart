import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/details/presentation/article_details_screen.dart';
import 'package:news_app/features/feed/presentation/widgets/article_cards.dart';
import 'support/app_test_harness.dart';

void main() {
  testWidgets('onboarding through feed, reactions, bookmarks and details', (tester) async {
    await bootstrap();
    await pumpApp(tester);

    expect(find.text('Set up my edition'), findsOneWidget);
    await tapAndSettle(tester, find.text('Set up my edition'));
    await tapAndSettle(tester, find.text('Technology'));
    await tapAndSettle(tester, find.text('Science'));
    await tapAndSettle(tester, find.text('Continue'));
    await tapAndSettle(tester, find.text('Start reading'));

    expect(find.byType(EditionArticleCard), findsWidgets);
    expect(find.text(flutterTitle), findsOneWidget);

    await tapAndSettle(tester, inCard(flutterTitle, find.byIcon(Icons.favorite_border_rounded)));
    expect(inCard(flutterTitle, find.text('185')), findsOneWidget);

    await tapAndSettle(tester, inCard(batteryTitle, find.byIcon(Icons.bookmark_outline_rounded)));
    expect(inCard(batteryTitle, find.byIcon(Icons.bookmark_rounded)), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('2 sections'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('2 sections'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(batteryTitle),
      -300,
      scrollable: find.byType(Scrollable).first,
    );

    await tapAndSettle(tester, navItem('Saved'));
    expect(find.text(batteryTitle), findsOneWidget);

    final dismissible = find.ancestor(of: find.text(batteryTitle), matching: find.byType(Dismissible));
    await tester.drag(dismissible, const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text(batteryTitle), findsNothing);
    expect(find.text('Removed from saved'), findsOneWidget);

    await tapAndSettle(tester, find.text('Undo'));
    expect(find.text(batteryTitle), findsOneWidget);

    await tapAndSettle(tester, find.text(batteryTitle));
    expect(find.byType(ArticleDetailsScreen), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.arrow_back_rounded));
    expect(find.byType(ArticleDetailsScreen), findsNothing);
    expect(find.text(batteryTitle), findsOneWidget);
  });

  testWidgets('queues a like while offline and syncs it from the pending chip', (tester) async {
    final api = await bootstrap(onboarded: true);
    await pumpApp(tester);
    expect(find.text(flutterTitle), findsOneWidget);

    api.simulateOffline = true;
    await tapAndSettle(tester, inCard(flutterTitle, find.byIcon(Icons.favorite_border_rounded)));
    expect(inCard(flutterTitle, find.text('185')), findsOneWidget);
    expect(find.text('1 pending change'), findsOneWidget);

    api.simulateOffline = false;
    await tapAndSettle(tester, find.text('1 pending change'));
    expect(find.text('1 pending change'), findsNothing);
    expect(inCard(flutterTitle, find.text('185')), findsOneWidget);
  });

  testWidgets('silently checks for new stories every tick while Home is visible (X2)', (tester) async {
    await bootstrap(onboarded: true);
    await pumpApp(tester);

    expect(find.text('0 new'), findsOneWidget);

    // AppShell's background tick defaults to 45s; MockApiClient.getFeedUpdates
    // always reports one fresh "breaking" item, so the pending pill should
    // appear on its own — no pull-to-refresh, no scroll.
    await tester.pump(const Duration(seconds: 45));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 new'), findsOneWidget);
    expect(find.text('0 new'), findsNothing);
  });
}
