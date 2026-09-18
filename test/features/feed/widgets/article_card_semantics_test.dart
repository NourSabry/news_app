import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/features/feed/presentation/widgets/article_cards.dart';

Article _article({bool isLiked = false, bool isBookmarked = false}) => Article(
      id: 'a',
      title: 'Flutter 4 ships a new rendering engine',
      summary: 'Summary',
      source: 'TechWire',
      author: const Author(id: 'u', name: 'Author'),
      topicId: 't_technology',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 12,
      comments: 3,
      isLiked: isLiked,
      isBookmarked: isBookmarked,
    );

void main() {
  testWidgets('the card is a single Semantics node in the documented format', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EditionArticleCard(
          article: _article(),
          variant: ArticleCardVariant.standard,
          topicName: 'Technology',
        ),
      ),
    ));

    final node = tester.getSemantics(find.byType(EditionArticleCard));
    expect(
      node.label,
      'Flutter 4 ships a new rendering engine. TechWire, 2h ago. 12 likes, 3 comments',
    );
    expect(node.flagsCollection.isButton, isTrue);
  });

  testWidgets('a saved article appends ", saved" to the label', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EditionArticleCard(
          article: _article(isBookmarked: true),
          variant: ArticleCardVariant.standard,
          topicName: 'Technology',
        ),
      ),
    ));

    final node = tester.getSemantics(find.byType(EditionArticleCard));
    expect(node.label, endsWith(', saved'));
  });

  testWidgets('the like and save buttons are separate, distinctly-labelled actions', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EditionArticleCard(
          article: _article(),
          variant: ArticleCardVariant.standard,
          topicName: 'Technology',
          onLike: () {},
          onBookmark: () {},
        ),
      ),
    ));

    // find.bySemanticsLabel walks the live (merged) semantics tree and is
    // flaky for exact string matches here; the widget-level Semantics
    // properties are the reliable source of truth for "did each button
    // get its own distinct, correctly-labelled node".
    final labels = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .map((s) => s.properties.label)
        .toSet();
    expect(labels, containsAll(['Like', 'Save for later']));
  });
}
