import 'package:equatable/equatable.dart';

class TrendingTopic extends Equatable {
  final String label;
  final int articleCount;

  const TrendingTopic({required this.label, required this.articleCount});

  factory TrendingTopic.fromJson(Map<String, dynamic> json) {
    return TrendingTopic(
      label: json['label'] as String,
      articleCount: (json['articleCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [label, articleCount];
}
