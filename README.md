# The Edition

[![CI](https://github.com/NourSabry/news_app/actions/workflows/ci.yml/badge.svg)](https://github.com/NourSabry/news_app/actions/workflows/ci.yml)

A Flutter news reader: a personal, paginated feed that keeps working offline, with optimistic
reactions, a durable outbox that syncs when you're back online, search with filters, bookmarks,
and deep links. There is no real backend — `MockApiClient` plays that part and keeps its own
persisted state, so likes and bookmarks survive a restart the way they would against a real API.

|  |  |  |

<img width="423" height="961" alt="Screenshot 2026-09-18 at 7 32 33 PM" src="https://github.com/user-attachments/assets/e6880a35-289f-4280-8e1e-e39150385805" />
<img width="443" height="934" alt="Screenshot 2026-09-18 at 7 32 47 PM" src="https://github.com/user-attachments/assets/c7b7a511-af22-43ef-bb57-59119ef6a1f6" />
<img width="437" height="955" alt="Screenshot 2026-09-18 at 7 33 03 PM" src="https://github.com/user-attachments/assets/7bc28b46-e576-44fa-9828-2f3f80f5abe0" />
<img width="458" height="974" alt="Screenshot 2026-09-18 at 7 33 54 PM" src="https://github.com/user-attachments/assets/b8bfb644-15b2-4d41-96e7-fa3b8a877ad7" />
<img width="453" height="976" alt="Screenshot 2026-09-18 at 7 33 39 PM" src="https://github.com/user-attachments/assets/dd733545-105c-4348-be81-5a8f13addf01" />
<img width="446" height="959" alt="Screenshot 2026-09-18 at 7 33 25 PM" src="https://github.com/user-attachments/assets/79b3707f-08c7-424e-bf74-264b649c4d30" />


## Setup

- Flutter 3.38 (stable) or newer, Dart `^3.10`.
- `flutter pub get`, then `flutter run`. First launch opens onboarding; pick a few sections and
  "Start reading" lands on a feed that's already loaded.
- `flutter analyze` is clean; `flutter test` runs 136 tests. Golden images live in `test/goldens/`
  — after an intentional visual change, regenerate with `flutter test --update-goldens` and review
  the diff before committing.
- CI (`.github/workflows/ci.yml`) runs `dart format --set-exit-if-changed`, `flutter analyze
  --fatal-infos` and the unit/widget suite on Linux, and the golden suite on macOS — goldens are
  pixel-exact to the platform that recorded them, so they run where they were recorded. Golden
  diffs are uploaded as an artifact when a run fails.
- **Deep links**: `newsfeed://article/{id}` (and `https://newsfeed.app/article/{id}`, see
  [Tradeoffs](#tradeoffs--known-limitations)).
  ```sh
  xcrun simctl openurl booted "newsfeed://article/a_flutter_roadmap"   # opens the article
  xcrun simctl openurl booted "newsfeed://article/a_removed_story"     # unavailable screen
  xcrun simctl openurl booted "newsfeed://nope"                        # feed + "That link didn't work"
  adb shell am start -a android.intent.action.VIEW -d "newsfeed://article/a_flutter_roadmap"
  ```
  Cold and warm starts both work; a link that arrives during onboarding is opened once it finishes.
- **Developer settings** (Settings → Developer, debug builds only) for demoing every failure path:
  simulate offline, server error, reaction conflict, reaction failure; network latency; cache
  freshness (30 min / always stale); background refresh interval; reset the mock server; replay
  onboarding.

## Architecture

Every feature is a `data` / `domain` / `presentation` slice; `core/` holds what's shared (network,
storage, theme, common widgets).

```
lib/
├── app/                # shell, floating dock, deep-link controller, router
├── core/
│   ├── network/        # ApiClient interface + MockApiClient
│   ├── storage/        # LocalStorage over Hive boxes (KeyValueStore abstraction for tests)
│   ├── theme/          # colour tokens + AppPalette, type scale, spacing, motion
│   └── widgets/        # dock, pills, buttons, banners, state views, skeletons
└── features/
    ├── feed/           # FeedBloc: pagination, refresh delta, trending scope, freshness
    ├── search/         # SearchBloc: debounce, filters, suggestions, section browse
    ├── details/        # DetailsBloc: cached-first article, related, unavailable state
    ├── bookmarks/      # BookmarksBloc: local-first ids, reconcile with server + outbox
    ├── reactions/      # ReactionsBloc: optimistic like, rollback, conflict, persistence
    ├── outbox/         # OutboxRepository + OutboxCubit: queue, sync, conflict review
    ├── settings/       # SettingsCubit: theme, sections, cache
    ├── onboarding/     # three-step onboarding with a live feed preview
    └── devtools/       # debug-only switches behind an interface
```

`presentation` depends on `domain` interfaces only; `ServiceLocator` wires the implementations at
startup and every one of them can be swapped in tests (the widget tests run the real app over an
in-memory store and a `MockApiClient` with zero latency).

Blocs (`FeedBloc`, `SearchBloc`, `DetailsBloc`, `ReactionsBloc`, `BookmarksBloc`) model features
where several kinds of event race each other and ordering matters; cubits (`SettingsCubit`,
`OutboxCubit`, `ConnectivityCubit`, `DevToolsCubit`) cover simple "call a method, state changes"
surfaces.

## Feed correctness

- **Cursor pagination** (`nextCursor`), merged by article id — a duplicate id is never shown twice.
- **Generation guard.** Every "replace everything" load (first load, section change, trending scope,
  new search) bumps a counter; load-more and refresh capture it when they start and drop their
  result if it no longer matches. A slow page 2 can't land in a feed the reader has already left.
- **Refresh delta.** `/feed/updates` returns `{new, updated, deleted}` ids. Updated items are
  replaced in place, deleted ones are removed with a notice, and new ones go into a *pending* list
  surfaced by the "N new stories" pill — the list under the reader's thumb never moves until they
  tap it. A background tick (every 45 s while Home is visible and the app is foregrounded) feeds
  the same path.
- **Trending** scopes the feed in place and never leaks into Explore's filters; Explore only ever
  receives an explicit filter set.

## Offline & sync

| Hive box | Contents | Lifetime |
|---|---|---|
| `feed_cache` | Feed pages by page number | Replaced on the next full load |
| `articles` | Article bodies by id | Overwritten on next fetch |
| `bookmarks` | Bookmarked ids | Until removed |
| `outbox` | Queued mutations keyed by idempotency key | Until applied or resolved as a conflict |
| `meta` | Last sync time, sections, recent searches, theme, onboarding flag, like overrides | Small single values |
| `mock_server` | The mock backend's own state: bookmarks, per-article likes/version, sync version | Only "Reset mock server" clears it |

**Freshness.** `cacheTtlMinutes` (from `/flags`, default 30) and `lastSyncedAt` derive
`fresh` / `stale` / `offline`; offline wins. One `FreshnessBanner` slot shows whichever applies,
and the outbox's own "N pending changes / syncing" status shares that slot rather than stacking.
Details shows a "Saved copy · 2h ago" caption when served from cache.

**Outbox.**

```
like / bookmark tapped ─▶ optimistic UI ─▶ enqueue {idempotencyKey, op, payload}
                                               │
connectivity regained ─────────────────────────▶ POST /sync {baseVersion, mutations}
                                               │
                              ┌────────────────┴────────────────┐
                          applied → dequeued          conflict → dequeued, server state
                                                      applied, ConflictReviewSheet shown
```

- Idempotency keys (UUID v4) mean a retried sync never double-applies.
- Like overrides carry a `version`; a stale optimistic value never overwrites a newer
  server-confirmed one.
- A server *rejection* (`TEMPORARY_FAILURE`) rolls the like back and offers Retry. Being offline
  queues it instead. Taps on an article whose toggle is in flight are ignored.
- On sync conflict the server wins (the response has no "force"); the sheet explains what changed.
- Bookmarks are local-first: the server list is merged with pending outbox changes on load, never
  used to overwrite local saves.

## Design

Two typefaces (Fraunces for headlines, Inter for everything else — both bundled, no network fonts),
pure white / near-black surfaces, no dividers or shadows on content, one coral accent used only for
like, live state and the selected pill. Colour otherwise comes from section tints on tags and
browse tiles. Navigation is a floating blurred dock; the lead story is a tall photo with the
headline set on it; empty and error states are typographic. Every colour resolves through a token
in `app_colors.dart` — there is no literal hex anywhere else in `lib/`.

Contrast (WCAG relative luminance, computed from the tokens):

| Pair | Light | Dark | Target |
|---|---|---|---|
| ink / background | 19.1 | 18.1 | 4.5 |
| inkMuted / background | 6.6 | 8.1 | 4.5 |
| accent / background (liked count) | 5.0 | 7.0 | 4.5 |
| warning / background | 5.9 | 9.9 | 4.5 |
| success / background | 5.3 | 9.1 | 4.5 |
| section tints / background | 4.7–6.2 | 8.0–10.6 | 4.5 |
| inkFaint / background (icons only) | 3.2 | 3.9 | 3.0 |

Accessibility: each card is a single semantics node ("title. source, time. N likes, M comments,
saved"), like/save are separate labelled actions, banners announce themselves, dock items carry
labels, tap targets are ≥ 48 px, and the layout reflows at large text sizes (thumbnails drop below
text). `test/accessibility/a11y_test.dart` runs Flutter's tap-target, label and text-contrast
guidelines over the feed states, details and saved screens.

## Scope

| Area | Status |
|---|---|
| Paginated feed, pull-to-refresh, dedup, refresh delta, pending pill | ✅ |
| Debounced search, suggestions, topic / source / date filters, recent searches | ✅ |
| Article details with content blocks, related stories, unavailable state | ✅ |
| Bookmarks: local-first, persisted, dedicated list, swipe to remove with undo | ✅ |
| Optimistic like: confirm / conflict / rollback, in-flight guard, persisted across restarts | ✅ |
| Offline: cached feed + articles, offline and stale banners, actions while offline | ✅ |
| Outbox with idempotency keys, sync on reconnect, conflict review | ✅ |
| Deep links (`newsfeed://`) with graceful unavailable / malformed handling, share | ✅ |
| Light / dark / system theme | ✅ |
| Tests: bloc unit tests, mock persistence, a11y guidelines, 20 goldens, full-app widget tests | ✅ |

## Tradeoffs & known limitations

- **Mock backend.** `MockApiClient` is the whole server, persisted locally so the offline / sync /
  conflict paths can be demonstrated without infrastructure. It also fabricates a "breaking" story
  on every `/feed/updates` call so the live-update path is visible in a demo.
- **Like is the only reaction**, matching the reaction endpoint in the brief.
- **`https://newsfeed.app/...` links** parse and are declared in both manifests, but verified
  Universal / App Links need an owned domain with hosted association files. The `newsfeed://`
  scheme is the fully working path.
- **Date filter** uses `publishedAt` only.
- **No authentication**; a single implicit user.
- Goldens cover the feed at 1.0× and 1.5× text scale; other screens at 2.0× were checked by hand.
