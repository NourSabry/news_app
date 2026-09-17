import 'package:equatable/equatable.dart';
import '../../domain/search_filters.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchStarted extends SearchEvent {
  const SearchStarted();
}

class QueryChanged extends SearchEvent {
  final String query;

  const QueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SubmitSearch extends SearchEvent {
  final String query;

  /// Null keeps whatever filters are already set (Explore typing/tapping a
  /// suggestion); an explicit value — typically [SearchFilters.none] —
  /// replaces them. A query must never silently inherit filters left over
  /// from a different entry point (B2).
  final SearchFilters? filters;

  const SubmitSearch(this.query, {this.filters});

  @override
  List<Object?> get props => [query, filters];
}

class LoadMoreResults extends SearchEvent {
  const LoadMoreResults();
}

class TopicFilterChanged extends SearchEvent {
  final String? topicId;

  const TopicFilterChanged(this.topicId);

  @override
  List<Object?> get props => [topicId];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}

class ClearRecentSearches extends SearchEvent {
  const ClearRecentSearches();
}
