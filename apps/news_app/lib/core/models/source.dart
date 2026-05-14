class SourceModel {
  SourceModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.baseUrl,
    required this.type,
    required this.enabled,
    required this.parserConfig,
  });

  factory SourceModel.fromJson(Map<String, dynamic> json) {
    return SourceModel(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      baseUrl: json['base_url'] as String,
      type: json['type'] as String? ?? 'rss',
      enabled: json['enabled'] as bool? ?? true,
      parserConfig: json['parser_config'] as String? ?? '{}',
    );
  }

  final int id;
  final int categoryId;
  final String name;
  final String baseUrl;
  final String type;
  final bool enabled;
  final String parserConfig;
}
