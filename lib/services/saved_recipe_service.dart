import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/exceptions.dart';
import '../models/saved_recipe.dart';

/// Akses tabel saved_recipes di Supabase. Hanya query, tanpa logika UI.
class SavedRecipeService {
  SavedRecipeService(this._client);

  final SupabaseClient _client;

  static const String _table = 'saved_recipes';

  Future<List<SavedRecipe>> fetchAll() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false);
      return rows.map(SavedRecipe.fromJson).toList();
    } on PostgrestException catch (error) {
      debugPrint(
        'fetchAll gagal: code=${error.code} message=${error.message} '
        'details=${error.details} hint=${error.hint}',
      );
      throw const AppException('Gagal memuat koleksi dari database.');
    } catch (error) {
      debugPrint('fetchAll error lain: $error');
      throw const AppException('Tidak dapat terhubung ke database.');
    }
  }

  Future<SavedRecipe> insert(SavedRecipe recipe) async {
    try {
      final row = await _client
          .from(_table)
          .insert(recipe.toInsertJson())
          .select()
          .single();
      return SavedRecipe.fromJson(row);
    } on PostgrestException catch (error) {
      debugPrint(
        'insert gagal: code=${error.code} message=${error.message} '
        'details=${error.details} hint=${error.hint}',
      );
      // 23505 = unique (user_id, meal_id) dilanggar.
      if (error.code == '23505') {
        throw const AppException('Resep sudah ada di koleksi.');
      }
      throw const AppException('Gagal menyimpan resep.');
    } catch (error) {
      debugPrint('insert error lain: $error');
      throw const AppException('Tidak dapat terhubung ke database.');
    }
  }
}
