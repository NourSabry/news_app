import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/connectivity/connectivity_cubit.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/core/theme/app_theme.dart';
import 'package:news_app/features/bookmarks/presentation/saved_screen.dart';
import 'package:news_app/features/details/presentation/article_details_screen.dart';
import 'package:news_app/features/devtools/presentation/cubit/dev_tools_cubit.dart';
import 'package:news_app/features/feed/domain/feed_repository.dart';
import 'package:news_app/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:news_app/features/feed/presentation/feed_screen.dart';

import '../support/app_test_harness.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

class MockConnectivityCubit extends MockCubit<ConnectivityStatus> implements ConnectivityCubit {}

FeedResponse _page(List<Article> data) =>
    FeedResponse(data: data, page: 1, pageSize: data.length, total: data.length);

/// every widget-tree state below must satisfy Android tap targets
/// (≥ 48×48dp), every tappable node must carry a label, and every visible
/// text/background pair must meet WCAG AA. `meetsGuideline` reports
/// exactly which node/pair fails, so a red run here is a real design bug,
/// not a flaky assertion.
Future<void> _checkGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

Future<FeedBloc> _feedBlocFor({
  required MockFeedRepository repository,
  required MockConnectivityCubit connectivity,
}) async {
  when(() => connectivity.isConnected).thenReturn(true);
  when(() => repository.getSelectedTopicIds()).thenReturn(const []);
  when(() => repository.getTopics()).thenAnswer((_) async => const []);
  when(() => repository.getTrending()).thenAnswer((_) async => const []);
  when(() => repository.getLastSyncTime()).thenReturn(null);
  when(() => repository.getCachedFeed()).thenReturn(null);
  when(() => repository.getCacheTtlMinutes()).thenAnswer((_) async => 30);
  return FeedBloc(repository, connectivity);
}

Future<void> _pumpFeedScreen(WidgetTester tester, FeedBloc bloc, {Brightness brightness = Brightness.light}) async {
  await tester.pumpWidget(MaterialApp(
    theme: brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
    // A Scaffold, not FeedScreen bare: without an opaque background behind
    // it, textContrastGuideline samples nothing (alpha 0) and reports a
    // false-positive failure — AppShell always provides one in the real app.
    home: Scaffold(
      body: BlocProvider.value(
        value: bloc,
        child: FeedScreen(onSearchTap: () {}),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  late SemanticsHandle handle;

  setUp(() {
    handle = TestWidgetsFlutterBinding.instance.ensureSemantics();
  });

  tearDown(() => handle.dispose());

  testWidgets('Feed loaded meets tap target, label and contrast guidelines', (tester) async {
    await bootstrap(onboarded: true);
    await pumpApp(tester);
    expect(find.text(flutterTitle), findsOneWidget);

    await _checkGuidelines(tester);
  });

  testWidgets('Feed empty meets tap target, label and contrast guidelines', (tester) async {
    final repository = MockFeedRepository();
    final connectivity = MockConnectivityCubit();
    when(() => repository.fetchPage(scope: null)).thenAnswer((_) async => _page(const []));
    final bloc = await _feedBlocFor(repository: repository, connectivity: connectivity)
      ..add(const LoadFeed());
    addTearDown(bloc.close);

    await _pumpFeedScreen(tester, bloc);
    expect(bloc.state.isEmpty, isTrue);
    expect(bloc.state.status, FeedStatus.success);

    await _checkGuidelines(tester);
  });

  testWidgets('Feed error meets tap target, label and contrast guidelines', (tester) async {
    final repository = MockFeedRepository();
    final connectivity = MockConnectivityCubit();
    when(() => repository.fetchPage(scope: null)).thenThrow(Exception('offline'));
    final bloc = await _feedBlocFor(repository: repository, connectivity: connectivity)
      ..add(const LoadFeed());
    addTearDown(bloc.close);

    await _pumpFeedScreen(tester, bloc);
    expect(bloc.state.status, FeedStatus.failure);

    await _checkGuidelines(tester);
  });

  testWidgets('Feed offline meets tap target, label and contrast guidelines', (tester) async {
    await bootstrap(onboarded: true);
    await pumpApp(tester);
    expect(find.text(flutterTitle), findsOneWidget);

    // Through DevToolsCubit, not just api.simulateOffline directly — that's
    // what actually flips ConnectivityCubit, which is what FeedState.isOffline
    // reads (same as the real Developer Settings toggle).
    tester.element(find.byType(FeedScreen)).read<DevToolsCubit>().setSimulateOffline(true);
    tester.element(find.byType(FeedScreen)).read<FeedBloc>().add(const RefreshFeed());
    await tester.pumpAndSettle();
    expect(find.textContaining("You're offline"), findsOneWidget);

    await _checkGuidelines(tester);
  });

  testWidgets('Details meets tap target, label and contrast guidelines', (tester) async {
    await bootstrap(onboarded: true);
    await pumpApp(tester);
    await tapAndSettle(tester, find.text(flutterTitle));
    expect(find.byType(ArticleDetailsScreen), findsOneWidget);

    await _checkGuidelines(tester);
  });

  testWidgets('Saved meets tap target, label and contrast guidelines', (tester) async {
    await bootstrap(onboarded: true);
    await pumpApp(tester);
    // a_flutter_roadmap is bookmarked by default in the mock dataset —
    // battery is not, so its bookmark icon reliably starts as the outline.
    await tester.scrollUntilVisible(
      find.text(batteryTitle),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tapAndSettle(tester, inCard(batteryTitle, find.byIcon(Icons.bookmark_outline_rounded)));
    await tapAndSettle(tester, navItem('Saved'));
    expect(find.byType(SavedScreen), findsOneWidget);

    await _checkGuidelines(tester);
  });
}
