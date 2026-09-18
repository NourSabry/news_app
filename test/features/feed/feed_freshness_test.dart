import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/feed/presentation/bloc/feed_bloc.dart';

void main() {
  final now = DateTime(2026, 9, 14, 12);

  test('fresh when never synced', () {
    const state = FeedState();
    expect(state.freshnessAt(now), FeedFreshness.fresh);
  });

  test('fresh when synced within the TTL', () {
    final state = FeedState(
      lastSyncedAt: now.subtract(const Duration(minutes: 10)),
    );
    expect(state.freshnessAt(now), FeedFreshness.fresh);
  });

  test('stale once the cache is older than the TTL', () {
    final state = FeedState(
      lastSyncedAt: now.subtract(const Duration(minutes: 31)),
    );
    expect(state.freshnessAt(now), FeedFreshness.stale);
  });

  test('a TTL of 0 is stale on the next open, even moments after syncing', () {
    final state = FeedState(lastSyncedAt: now, cacheTtlMinutes: 0);
    expect(state.freshnessAt(now), FeedFreshness.stale);
  });

  test('offline wins over stale', () {
    final state = FeedState(
      lastSyncedAt: now.subtract(const Duration(hours: 3)),
      isOffline: true,
    );
    expect(state.freshnessAt(now), FeedFreshness.offline);
  });
}
