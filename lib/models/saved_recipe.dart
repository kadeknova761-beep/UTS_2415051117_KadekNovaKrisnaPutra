/// Resep yang disimpan pengguna di database (tabel saved_recipes).
///
/// API menyediakan katalog, sedangkan model ini menyimpan data personal:
/// catatan, rating, dan status "sudah dimasak".
class SavedRecipe {
  /// Dibuat otomatis oleh database, null sebelum data disimpan.
  final int? id;
  final String studentId;
  final String mealId;
  final String mealName;
  final String? thumbnailUrl;
  final String note;
  final int rating;
  final bool isCooked;
  final DateTime? createdAt;

  const SavedRecipe({
    this.id,
    required this.studentId,
    required this.mealId,
    required this.mealName,
    this.thumbnailUrl,
    this.note = '',
    required this.rating,
    this.isCooked = false,
    this.createdAt,
  });

  factory SavedRecipe.fromJson(Map<String, dynamic> json) {
    return SavedRecipe(
      id: json['id'] as int?,
      studentId: json['student_id'] as String,
      mealId: json['meal_id'] as String,
      mealName: json['meal_name'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      note: (json['note'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      isCooked: (json['is_cooked'] as bool?) ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  /// Data untuk INSERT. id dan created_at diisi oleh database.
  Map<String, dynamic> toInsertJson() {
    return {
      'student_id': studentId,
      'meal_id': mealId,
      'meal_name': mealName,
      'thumbnail_url': thumbnailUrl,
      'note': note,
      'rating': rating,
      'is_cooked': isCooked,
    };
  }

  /// Data untuk UPDATE. Hanya field yang boleh diubah pengguna.
  Map<String, dynamic> toUpdateJson() {
    return {'note': note, 'rating': rating, 'is_cooked': isCooked};
  }

  SavedRecipe copyWith({String? note, int? rating, bool? isCooked}) {
    return SavedRecipe(
      id: id,
      studentId: studentId,
      mealId: mealId,
      mealName: mealName,
      thumbnailUrl: thumbnailUrl,
      note: note ?? this.note,
      rating: rating ?? this.rating,
      isCooked: isCooked ?? this.isCooked,
      createdAt: createdAt,
    );
  }
}
