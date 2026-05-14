class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.enabled,
    required this.includeKeywords,
    required this.excludeKeywords,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      enabled: json['enabled'] as bool? ?? true,
      includeKeywords: json['include_keywords'] as String? ?? '',
      excludeKeywords: json['exclude_keywords'] as String? ?? '',
    );
  }

  final int id;
  final String name;
  final int sortOrder;
  final bool enabled;
  final String includeKeywords;
  final String excludeKeywords;
}
