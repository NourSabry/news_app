import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/search/domain/search_filters.dart';

void main() {
  test('none is empty with zero active filters', () {
    expect(SearchFilters.none.isEmpty, isTrue);
    expect(SearchFilters.none.activeCount, 0);
  });

  test('activeCount counts only the set fields', () {
    final filters = SearchFilters(topicId: 't_technology', date: DateRange.today());
    expect(filters.isEmpty, isFalse);
    expect(filters.activeCount, 2);
  });

  test('copyWith can explicitly clear a field back to null', () {
    const filters = SearchFilters(topicId: 't_technology', source: 'Mobile Daily');
    final cleared = filters.copyWith(topicId: null);
    expect(cleared.topicId, isNull);
    expect(cleared.source, 'Mobile Daily');
  });

  test('past7Days spans exactly 7 days ending now', () {
    final now = DateTime(2026, 9, 17, 12);
    final range = DateRange.past7Days(now: now);
    expect(range.to, now);
    expect(range.from, DateTime(2026, 9, 10));
  });
}
