/// Kategori resep dari TheMealDB (categories.php).
class MealCategory {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String description;

  const MealCategory({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.description,
  });

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    final name = json['strCategory'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Data kategori tidak lengkap (strCategory).');
    }
    return MealCategory(
      id: (json['idCategory'] as String?) ?? '',
      name: name.trim(),
      thumbnailUrl: (json['strCategoryThumb'] as String?) ?? '',
      description: (json['strCategoryDescription'] as String?) ?? '',
    );
  }
}
