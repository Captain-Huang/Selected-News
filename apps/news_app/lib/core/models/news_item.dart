class NewsItemModel {
  NewsItemModel({
    required this.id,
    required this.categoryId,
    required this.sourceId,
    required this.title,
    required this.summary,
    required this.url,
    required this.coverImage,
    required this.publishedAt,
    required this.fetchedAt,
    required this.tags,
    required this.score,
  });

  factory NewsItemModel.fromJson(Map<String, dynamic> json) {
    return NewsItemModel(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      sourceId: json['source_id'] as int,
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      url: json['url'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
      publishedAt:
          DateTime.tryParse(json['published_at'] as String? ?? '') ??
          DateTime.now(),
      fetchedAt:
          DateTime.tryParse(json['fetched_at'] as String? ?? '') ??
          DateTime.now(),
      tags: json['tags'] as String? ?? '[]',
      score: json['score'] as int? ?? 0,
    );
  }

  final int id;
  final int categoryId;
  final int sourceId;
  final String title;
  final String summary;
  final String url;
  final String coverImage;
  final DateTime publishedAt;
  final DateTime fetchedAt;
  final String tags;
  final int score;
}
