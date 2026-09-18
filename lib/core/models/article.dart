import 'package:equatable/equatable.dart';
import 'author.dart';
import 'content_block.dart';

class Article extends Equatable {
  final String id;
  final String title;
  final String summary;
  final String source;
  final Author author;
  final String topicId;
  final DateTime publishedAt;
  final DateTime? updatedAt;
  final String? image;
  final List<String> tags;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isBookmarked;
  final int? readTimeMinutes;
  final List<ContentBlock>? body;
  final List<String>? related;
  final int version;

  /// True when the publisher removed this story. Set locally when a
  /// fetch resolves to [ArticleUnavailable] — never round-trips through
  /// the API/cache JSON, since it isn't the article's own data.
  final bool isUnavailable;

  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.author,
    required this.topicId,
    required this.publishedAt,
    this.updatedAt,
    this.image,
    this.tags = const [],
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.readTimeMinutes,
    this.body,
    this.related,
    this.version = 1,
    this.isUnavailable = false,
  });

  Article copyWith({
    String? id,
    String? title,
    String? summary,
    String? source,
    Author? author,
    String? topicId,
    DateTime? publishedAt,
    DateTime? updatedAt,
    String? image,
    List<String>? tags,
    int? likes,
    int? comments,
    bool? isLiked,
    bool? isBookmarked,
    int? readTimeMinutes,
    List<ContentBlock>? body,
    List<String>? related,
    int? version,
    bool? isUnavailable,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      source: source ?? this.source,
      author: author ?? this.author,
      topicId: topicId ?? this.topicId,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      image: image ?? this.image,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      body: body ?? this.body,
      related: related ?? this.related,
      version: version ?? this.version,
      isUnavailable: isUnavailable ?? this.isUnavailable,
    );
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      source: json['source'] as String,
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      topicId: json['topicId'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      image: json['image'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      readTimeMinutes: (json['readTimeMinutes'] as num?)?.toInt(),
      body: (json['body'] as List<dynamic>?)
          ?.map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
      related: (json['related'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      version: (json['version'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'source': source,
      'author': author.toJson(),
      'topicId': topicId,
      'publishedAt': publishedAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (image != null) 'image': image,
      'tags': tags,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      if (readTimeMinutes != null) 'readTimeMinutes': readTimeMinutes,
      if (body != null) 'body': body!.map((b) => b.toJson()).toList(),
      if (related != null) 'related': related,
      'version': version,
    };
  }

  @override
  List<Object?> get props => [
    id,
    version,
    isLiked,
    isBookmarked,
    likes,
    isUnavailable,
  ];
}
