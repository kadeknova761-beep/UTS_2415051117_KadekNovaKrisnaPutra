import 'package:flutter/foundation.dart';

import '../core/exceptions.dart';
import '../core/load_status.dart';
import '../models/meal.dart';
import '../repositories/meal_repository.dart';

/// State detail resep, disimpan per id resep.
///
/// Resep yang sudah dimuat disimpan sebagai cache, sehingga membuka detail
/// yang sama lagi tidak memanggil API ulang.
class RecipeDetailProvider extends ChangeNotifier {
  RecipeDetailProvider(this._repository);

  final MealRepository _repository;

  final Map<String, Meal> _details = {};
  final Map<String, LoadStatus> _statuses = {};
  final Map<String, String> _errors = {};
  bool _disposed = false;

  LoadStatus statusOf(String id) => _statuses[id] ?? LoadStatus.initial;

  /// Detail lengkap hasil pemuatan, atau null bila belum ada.
  Meal? detailOf(String id) => _details[id];

  String? errorOf(String id) => _errors[id];

  /// Memastikan detail [meal] tersedia.
  ///
  /// - Sudah dimuat atau sedang dimuat: tidak melakukan apa-apa.
  /// - [meal] sudah membawa detail (dari search/random): dipakai langsung.
  /// - Selain itu: diambil lewat repository. Status error boleh dicoba lagi
  ///   dengan memanggil method ini kembali.
  Future<void> load(Meal meal) async {
    final id = meal.id;
    final current = statusOf(id);
    if (current == LoadStatus.loading ||
        current == LoadStatus.success ||
        current == LoadStatus.empty) {
      return;
    }

    if (meal.hasDetail) {
      _store(id, meal);
      _notify();
      return;
    }

    _statuses[id] = LoadStatus.loading;
    _errors.remove(id);
    _notify();

    try {
      _store(id, await _repository.getMealDetail(id));
    } on Exception catch (error) {
      _errors[id] = error is AppException
          ? error.message
          : 'Terjadi kesalahan. Silakan coba lagi.';
      _statuses[id] = LoadStatus.error;
    }
    _notify();
  }

  void _store(String id, Meal detail) {
    _details[id] = detail;
    final isEmpty = detail.ingredients.isEmpty && detail.steps.isEmpty;
    _statuses[id] = isEmpty ? LoadStatus.empty : LoadStatus.success;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
