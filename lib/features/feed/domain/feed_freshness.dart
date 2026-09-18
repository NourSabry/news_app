/// Feed cache freshness: distinct from a permanent "Updated Xm
/// ago" line — surfaced as a banner only when the reader isn't looking at
/// a fresh feed.
enum FeedFreshness { fresh, stale, offline }
