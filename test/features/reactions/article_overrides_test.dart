import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/features/reactions/domain/article_overrides.dart';

Article article({int version = 1}) => Article(
  id: 'a',
  title: 'Title',
  summary: 'Summary',
  source: 'Source',
  author: const Author(id: 'u', name: 'Author'),
  topicId: 't_technology',
  publishedAt: DateTime(2026, 9, 14),
  likes: 10,
  version: version,
);

void main() {
  const overrides = ArticleOverrides(isLiked: true, likes: 11, version: 2);

  test('applying overrides replaces like state, count and version', () {
    final result = article().applying(overrides);
    expect(result.isLiked, isTrue);
    expect(result.likes, 11);
    expect(result.version, 2);
  });

  test('applying null leaves the article untouched', () {
    expect(article().applying(null), article());
  });

  test('newer server data wins over stale overrides', () {
    final fresh = article(version: 3);
    expect(fresh.applying(overrides), fresh);
    expect(fresh.applying(overrides).likes, 10);
  });
}
