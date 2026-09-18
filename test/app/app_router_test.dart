import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/app_router.dart';

void main() {
  test("newsfeed://article/x parses to ArticleRoute('x')", () {
    expect(
      AppRouter.parse('newsfeed://article/a_flutter_roadmap'),
      const ArticleRoute('a_flutter_roadmap'),
    );
  });

  test('the https:// form parses to the same route', () {
    expect(
      AppRouter.parse('https://newsfeed.app/article/a_flutter_roadmap'),
      const ArticleRoute('a_flutter_roadmap'),
    );
  });

  test('an unrecognised scheme/host is malformed → null', () {
    expect(AppRouter.parse('https://example.com/article/a'), isNull);
  });

  test('a missing id is malformed → null', () {
    expect(AppRouter.parse('newsfeed://article/'), isNull);
    expect(AppRouter.parse('https://newsfeed.app/article/'), isNull);
  });

  test('garbage input is malformed → null', () {
    expect(AppRouter.parse('garbage'), isNull);
    expect(AppRouter.parse(''), isNull);
  });

  test('articleShareLink round-trips through parse', () {
    final link = AppRouter.articleShareLink('a_flutter_roadmap');
    expect(
      AppRouter.parse(link.toString()),
      const ArticleRoute('a_flutter_roadmap'),
    );
  });
}
