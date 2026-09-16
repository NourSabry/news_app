import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';

const _unset = Object();

class SearchState extends Equatable {
  final String query;
  final List<String> suggestions;
  final List<Article> results;
  final String? nextCursor;
  final String? selectedTopicId;
  final List<Topic> topics;
  final List<String> recentSearches;
  final bool hasSearched;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  const SearchState({
    this.query = '',
    this.suggestions = const [],
    this.results = const [],
    this.nextCursor,
    this.selectedTopicId,
    this.topics = const [],
    this.recentSearches = const [],
    this.hasSearched = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  bool get hasMore => nextCursor != null;
  bool get canLoadMore => hasSearched && hasMore && !isLoading && !isLoadingMore;

  String topicNameFor(String topicId) => topics.nameFor(topicId);

  SearchState copyWith({
    String? query,
    List<String>? suggestions,
    List<Article>? results,
    Object? nextCursor = _unset,
    Object? selectedTopicId = _unset,
    List<Topic>? topics,
    List<String>? recentSearches,
    bool? hasSearched,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _unset,
  }) {
    return SearchState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      results: results ?? this.results,
      nextCursor: identical(nextCursor, _unset) ? this.nextCursor : nextCursor as String?,
      selectedTopicId:
          identical(selectedTopicId, _unset) ? this.selectedTopicId : selectedTopicId as String?,
      topics: topics ?? this.topics,
      recentSearches: recentSearches ?? this.recentSearches,
      hasSearched: hasSearched ?? this.hasSearched,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        query,
        suggestions,
        results,
        nextCursor,
        selectedTopicId,
        topics,
        recentSearches,
        hasSearched,
        isLoading,
        isLoadingMore,
        errorMessage,
      ];
}
