import 'package:equatable/equatable.dart';

enum DateRangePreset { today, past7Days, past30Days, custom }

/// A `publishedAt` range filter (G1). [from]/[to] are computed for the
/// presets and explicit for [DateRangePreset.custom].
class DateRange extends Equatable {
  final DateRangePreset preset;
  final DateTime from;
  final DateTime to;

  const DateRange({required this.preset, required this.from, required this.to});

  factory DateRange.today({DateTime? now}) {
    final today = _startOfDay(now ?? DateTime.now());
    return DateRange(preset: DateRangePreset.today, from: today, to: today.add(const Duration(days: 1)));
  }

  factory DateRange.past7Days({DateTime? now}) => _pastDays(7, now: now, preset: DateRangePreset.past7Days);

  factory DateRange.past30Days({DateTime? now}) =>
      _pastDays(30, now: now, preset: DateRangePreset.past30Days);

  factory DateRange.custom({required DateTime from, required DateTime to}) {
    return DateRange(preset: DateRangePreset.custom, from: _startOfDay(from), to: to);
  }

  static DateRange _pastDays(int days, {DateTime? now, required DateRangePreset preset}) {
    final end = now ?? DateTime.now();
    return DateRange(preset: preset, from: _startOfDay(end.subtract(Duration(days: days))), to: end);
  }

  static DateTime _startOfDay(DateTime time) => DateTime(time.year, time.month, time.day);

  @override
  List<Object?> get props => [preset, from, to];
}

const _unset = Object();

/// Search filters (G1): topic, source and date, all optional. `SubmitSearch`
/// carries this so a query never silently inherits filters from a different
/// entry point (B2) — callers outside Explore must pass an explicit set
/// (typically [SearchFilters.none]); Explore itself passes null to keep
/// whatever the user already chose.
class SearchFilters extends Equatable {
  final String? topicId;
  final String? source;
  final DateRange? date;

  const SearchFilters({this.topicId, this.source, this.date});

  static const none = SearchFilters();

  bool get isEmpty => topicId == null && source == null && date == null;

  int get activeCount => [topicId, source, date].where((value) => value != null).length;

  SearchFilters copyWith({
    Object? topicId = _unset,
    Object? source = _unset,
    Object? date = _unset,
  }) {
    return SearchFilters(
      topicId: identical(topicId, _unset) ? this.topicId : topicId as String?,
      source: identical(source, _unset) ? this.source : source as String?,
      date: identical(date, _unset) ? this.date : date as DateRange?,
    );
  }

  @override
  List<Object?> get props => [topicId, source, date];
}
