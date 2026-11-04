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

  /// Awalan "Step 3", "STEP 1:", dan sejenisnya.
  static final RegExp _stepPrefix = RegExp(
    r'^step\s*\d+\s*[.):\-]?\s*',
    caseSensitive: false,
  );

  /// Awalan "1." atau "2)" yang diikuti spasi. Angka yang menempel pada
  /// kalimat ("1.5 cangkir", "2 sendok") tidak ikut terpotong.
  static final RegExp _numberPrefix = RegExp(r'^\d+\s*[.)]\s+');

  /// Baris yang isinya hanya nomor, misalnya "1" atau "2.".
  static final RegExp _numberOnly = RegExp(r'^\d+\s*[.)]?$');

  /// True jika data ini berasal dari endpoint lookup (detail lengkap).
  bool get hasDetail => instructions != null;

  /// Langkah memasak, dipecah per baris dari teks instruksi.
  /// Penomoran bawaan teks dibuang karena layar detail menomori sendiri.
  List<String> get steps {
    final text = instructions;
    if (text == null) return const [];
    return text
        .split(RegExp(r'\r?\n'))
        .map(_cleanStep)
        .where((line) => line.isNotEmpty && !_numberOnly.hasMatch(line))
        .toList();
  }

  static String _cleanStep(String line) {
    return line
        .trim()
        .replaceFirst(_stepPrefix, '')
        .replaceFirst(_numberPrefix, '')
        .trim();
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
