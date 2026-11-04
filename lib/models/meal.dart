/// Satu bahan beserta takarannya, misalnya "Chicken" - "500g".
class MealIngredient {
  final String name;
  final String measure;

  const MealIngredient({required this.name, required this.measure});
}

/// Model resep dari TheMealDB.
///
/// Endpoint filter/search hanya mengembalikan id, nama, dan thumbnail,
/// sedangkan endpoint lookup mengembalikan data lengkap. Karena itu field
/// detail dibuat nullable.
class Meal {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String? category;
  final String? area;
  final String? instructions;
  final String? youtubeUrl;
  final List<String> tags;
  final List<MealIngredient> ingredients;

  const Meal({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    this.category,
    this.area,
    this.instructions,
    this.youtubeUrl,
    this.tags = const [],
    this.ingredients = const [],
  });

  /// True jika data ini berasal dari endpoint lookup (detail lengkap).
  bool get hasDetail => instructions != null;

  /// Langkah memasak, dipecah per baris dari teks instruksi.
  List<String> get steps {
    final text = instructions;
    if (text == null) return const [];
    return text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    final id = _clean(json['idMeal']);
    final name = _clean(json['strMeal']);
    if (id == null || name == null) {
      throw const FormatException('Data resep tidak lengkap (idMeal/strMeal).');
    }

    // TheMealDB menyimpan bahan di strIngredient1..20 dan strMeasure1..20.
    final ingredients = <MealIngredient>[];
    for (var i = 1; i <= 20; i++) {
      final ingredient = _clean(json['strIngredient$i']);
      if (ingredient == null) continue;
      final measure = _clean(json['strMeasure$i']) ?? '';
      ingredients.add(MealIngredient(name: ingredient, measure: measure));
    }

    final rawTags = _clean(json['strTags']);
    final tags = rawTags == null
        ? <String>[]
        : rawTags
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();

    return Meal(
      id: id,
      name: name,
      thumbnailUrl: _clean(json['strMealThumb']) ?? '',
      category: _clean(json['strCategory']),
      area: _clean(json['strArea']),
      instructions: _clean(json['strInstructions']),
      youtubeUrl: _clean(json['strYoutube']),
      tags: tags,
      ingredients: ingredients,
    );
  }

  /// Mengembalikan String yang sudah di-trim, atau null jika kosong/bukan String.
  static String? _clean(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
