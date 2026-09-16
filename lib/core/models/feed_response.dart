import 'article.dart';

class FeedResponse {
  final List<Article> data;
  final int page;
  final int pageSize;
  final int total;
  final String? nextCursor;

  const FeedResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.total,
    this.nextCursor,
  });

  bool get hasMore => nextCursor != null;

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
