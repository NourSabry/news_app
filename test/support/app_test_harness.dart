import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/di/service_locator.dart';
import 'package:news_app/core/network/mock_api_client.dart';
import 'package:news_app/core/storage/local_storage.dart';
import 'package:news_app/core/widgets/edition_nav_bar.dart';
import 'package:news_app/features/feed/presentation/widgets/article_cards.dart';
import 'package:news_app/main.dart';

/// Shared full-app test harness (`widget_test.dart`, T4 a11y, T5 goldens) —
/// a real `NewsApp` over an in-memory store and a `MockApiClient`, so every
/// screen state is reached the same way a reader would, not hand-assembled.
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

Future<void> pumpApp(WidgetTester tester, {Size size = const Size(1170, 2532), double pixelRatio = 3}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const NewsApp());
  await tester.pumpAndSettle();
}

Finder inCard(String title, Finder matching) {
  final card = find.ancestor(of: find.text(title), matching: find.byType(EditionArticleCard));
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
