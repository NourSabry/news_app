import 'package:equatable/equatable.dart';

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

  const SubmitSearch(this.query);

  @override
  List<Object?> get props => [query];
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
