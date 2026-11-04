/// Resep yang disimpan pengguna di database (tabel saved_recipes).
///
/// API menyediakan katalog, sedangkan model ini menyimpan data personal:
/// catatan dan rating. Kepemilikan baris (user_id) diisi database dari
/// sesi login anonim, dijaga oleh RLS.
class SavedRecipe {
  /// Dibuat otomatis oleh database (uuid), null sebelum data disimpan.
  final String? id;
  final String mealId;
  final String mealName;
  final String? thumbnailUrl;
  final String note;

  /// 1-5, atau null bila belum dinilai.
  final int? rating;
  final DateTime? createdAt;

  const SavedRecipe({
    this.id,
    required this.mealId,
    required this.mealName,
    this.thumbnailUrl,
    this.note = '',
    this.rating,
    this.createdAt,
  });

  factory SavedRecipe.fromJson(Map<String, dynamic> json) {
    return SavedRecipe(
      id: json['id'] as String?,
      mealId: json['meal_id'] as String,
      mealName: json['meal_name'] as String,
      thumbnailUrl: json['meal_thumb'] as String?,
      note: (json['note'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
    );
  }

  /// Data untuk INSERT. id, user_id, dan created_at diisi oleh database.
  Map<String, dynamic> toInsertJson() {
    return {
      'meal_id': mealId,
      'meal_name': mealName,
      'meal_thumb': thumbnailUrl,
      'note': note,
      'rating': rating,
    };
  }

  /// Data untuk UPDATE. Hanya field yang boleh diubah pengguna.
  Map<String, dynamic> toUpdateJson() {
    return {'note': note, 'rating': rating};
  }

  SavedRecipe copyWith({String? note, int? rating}) {
    return SavedRecipe(
      id: id,
      mealId: mealId,
      mealName: mealName,
      thumbnailUrl: thumbnailUrl,
      note: note ?? this.note,
      rating: rating ?? this.rating,
      createdAt: createdAt,
    );
  }
}
