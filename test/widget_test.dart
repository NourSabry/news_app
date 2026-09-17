import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/di/service_locator.dart';
import 'package:news_app/core/network/mock_api_client.dart';
import 'package:news_app/core/storage/local_storage.dart';
import 'package:news_app/core/widgets/edition_nav_bar.dart';
import 'package:news_app/features/details/presentation/article_details_screen.dart';
import 'package:news_app/features/feed/presentation/widgets/article_card.dart';
import 'package:news_app/main.dart';

class MockConnectivity extends Mock implements Connectivity {}

class MockCacheManager extends Mock implements BaseCacheManager {}

const flutterTitle = 'Flutter Team Shares the Next Performance Roadmap';
const batteryTitle = 'Battery Breakthrough Improves Grid Storage Efficiency';

Future<MockApiClient> bootstrap({bool onboarded = false}) async {
  final storage = LocalStorage.inMemory();
  if (onboarded) await storage.setOnboardingCompleted(true);

  final connectivity = MockConnectivity();
  when(() => connectivity.onConnectivityChanged).thenAnswer((_) => const Stream.empty());

  final images = MockCacheManager();
  when(() => images.getFileStream(
        any(),
        key: any(named: 'key'),
        headers: any(named: 'headers'),
        withProgress: any(named: 'withProgress'),
      )).thenAnswer((_) => Stream.error(Exception('No images in tests')));

  final api = MockApiClient()..latencyMs = 0;
  rootBundle.clear();
  ServiceLocator.instance.reset();
  await ServiceLocator.instance.init(
    storage: storage,
    apiClient: api,
    connectivity: connectivity,
    imageCache: images,
  );
  return api;
}

Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const NewsApp());
  await tester.pumpAndSettle();
}

Finder inCard(String title, Finder matching) {
  final card = find.ancestor(of: find.text(title), matching: find.byType(ArticleCard));
  return find.descendant(of: card, matching: matching);
}

Finder navItem(String label) {
  return find.descendant(
    of: find.byType(EditionNavBar),
    matching: find.text(label.toUpperCase()),
  );
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('onboarding through feed, reactions, bookmarks and details', (tester) async {
    await bootstrap();
    await pumpApp(tester);

    expect(find.text('News Feed'), findsOneWidget);
    await tapAndSettle(tester, find.text('Continue'));
    await tapAndSettle(tester, find.text('Technology'));
    await tapAndSettle(tester, find.text('Science'));
    await tapAndSettle(tester, find.text('Continue'));
    await tapAndSettle(tester, find.text('Get started'));

    expect(find.byType(ArticleCard), findsWidgets);
    expect(find.textContaining('Showing 2 topics'), findsOneWidget);
    expect(find.text('Updated just now'), findsOneWidget);
    expect(find.text(flutterTitle), findsOneWidget);

    await tapAndSettle(tester, inCard(flutterTitle, find.byTooltip('Like')));
    expect(inCard(flutterTitle, find.text('185')), findsOneWidget);

    await tapAndSettle(tester, inCard(batteryTitle, find.byTooltip('Save')));
    expect(inCard(batteryTitle, find.byTooltip('Remove bookmark')), findsOneWidget);

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

    await tapAndSettle(tester, find.byTooltip('Back'));
    expect(find.byType(ArticleDetailsScreen), findsNothing);
    expect(find.text(batteryTitle), findsOneWidget);
  });

  testWidgets('queues a like while offline and syncs it from the pending chip', (tester) async {
    final api = await bootstrap(onboarded: true);
    await pumpApp(tester);
    expect(find.text(flutterTitle), findsOneWidget);

    api.simulateOffline = true;
    await tapAndSettle(tester, inCard(flutterTitle, find.byTooltip('Like')));
    expect(inCard(flutterTitle, find.text('185')), findsOneWidget);
    expect(find.text('1 pending change'), findsOneWidget);

    api.simulateOffline = false;
    await tapAndSettle(tester, find.text('1 pending change'));
    expect(find.text('1 pending change'), findsNothing);
    expect(inCard(flutterTitle, find.text('185')), findsOneWidget);
  });
}
