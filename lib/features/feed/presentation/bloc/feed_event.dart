import 'package:equatable/equatable.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeed extends FeedEvent {
  const LoadFeed();
}

class LoadMoreFeed extends FeedEvent {
  const LoadMoreFeed();
}

class RefreshFeed extends FeedEvent {
  const RefreshFeed();
}

class ShowPendingArticles extends FeedEvent {
  const ShowPendingArticles();
}

class TopicSelectionChanged extends FeedEvent {
  const TopicSelectionChanged();
}

/// Scopes the feed to a trending label, or clears the scope back to the
/// personal feed when [label] is null (B2). Never touches Explore/search.
class FeedScopeChanged extends FeedEvent {
  final String? label;

  const FeedScopeChanged(this.label);

  @override
  List<Object?> get props => [label];
}
