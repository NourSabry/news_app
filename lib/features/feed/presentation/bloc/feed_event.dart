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
