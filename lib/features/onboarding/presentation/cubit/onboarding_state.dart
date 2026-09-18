import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';

class OnboardingState extends Equatable {
  final List<Article> headlines;
  final List<Article> preview;
  final bool isLoadingPreview;
  final Map<String, int> topicCounts;

  /// One representative image per topic, for the section tiles.
  final Map<String, String> topicCovers;

  const OnboardingState({
    this.headlines = const [],
    this.preview = const [],
    this.isLoadingPreview = false,
    this.topicCounts = const {},
    this.topicCovers = const {},
  });

  OnboardingState copyWith({
    List<Article>? headlines,
    List<Article>? preview,
    bool? isLoadingPreview,
    Map<String, int>? topicCounts,
    Map<String, String>? topicCovers,
  }) {
    return OnboardingState(
      headlines: headlines ?? this.headlines,
      preview: preview ?? this.preview,
      isLoadingPreview: isLoadingPreview ?? this.isLoadingPreview,
      topicCounts: topicCounts ?? this.topicCounts,
      topicCovers: topicCovers ?? this.topicCovers,
    );
  }

  @override
  List<Object?> get props => [
    headlines,
    preview,
    isLoadingPreview,
    topicCounts,
    topicCovers,
  ];
}
