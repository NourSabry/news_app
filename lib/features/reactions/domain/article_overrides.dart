import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';

class ArticleOverrides extends Equatable {
  final bool isLiked;
  final int likes;
  final int version;

  const ArticleOverrides({
    required this.isLiked,
    required this.likes,
    required this.version,
  });

  factory ArticleOverrides.fromJson(Map<String, dynamic> json) {
    return ArticleOverrides(
      isLiked: json['isLiked'] as bool? ?? false,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      version: (json['version'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {'isLiked': isLiked, 'likes': likes, 'version': version};
  }

  @override
  List<Object?> get props => [isLiked, likes, version];
}

extension ArticleOverriding on Article {
  Article applying(ArticleOverrides? overrides) {
    if (overrides == null || overrides.version < version) return this;
    return copyWith(
      isLiked: overrides.isLiked,
      likes: overrides.likes,
      version: overrides.version,
    );
  }
}
