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

  /// Memperbarui catatan dan rating. Baris dicari lewat id; RLS memastikan
  /// hanya baris milik pengguna yang bisa berubah.
  Future<SavedRecipe> update(SavedRecipe recipe) async {
    final id = recipe.id;
    if (id == null) {
      throw const AppException('Resep belum tersimpan di database.');
    }
    try {
      final row = await _client
          .from(_table)
          .update(recipe.toUpdateJson())
          .eq('id', id)
          .select()
          .single();
      return SavedRecipe.fromJson(row);
    } on PostgrestException catch (error) {
      debugPrint(
        'update gagal: code=${error.code} message=${error.message} '
        'details=${error.details} hint=${error.hint}',
      );
      throw const AppException('Gagal memperbarui resep.');
    } catch (error) {
      debugPrint('update error lain: $error');
      throw const AppException('Tidak dapat terhubung ke database.');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } on PostgrestException catch (error) {
      debugPrint(
        'delete gagal: code=${error.code} message=${error.message} '
        'details=${error.details} hint=${error.hint}',
      );
      throw const AppException('Gagal menghapus resep.');
    } catch (error) {
      debugPrint('delete error lain: $error');
      throw const AppException('Tidak dapat terhubung ke database.');
    }
  }
}
